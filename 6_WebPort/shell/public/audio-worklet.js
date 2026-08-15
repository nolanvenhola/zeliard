class ZeliardPcmProcessor extends AudioWorkletProcessor {
    constructor() {
        super();
        this.chunks = [];
        this.chunkOffset = 0;
        this.bufferedFrames = 0;
        this.primeTargetFrames = 4096;
        this.primed = false;
        this.lastLeft = 0;
        this.lastRight = 0;
        this.fadeInFrames = 0;
        this.crossfadeFrames = 0;
        this.crossfadeLeft = 0;
        this.crossfadeRight = 0;
        this.callbacksSinceStats = 0;
        this.stats = {
            callbacks: 0,
            requestedFrames: 0,
            deliveredFrames: 0,
            underrunFrames: 0,
            deliveredPeak: 0,
            deliveredNonzero: 0,
            bufferedFrames: 0,
        };
        this.port.onmessage = (event) => {
            if (event.data?.type === 'reset') {
                this.chunks.length = 0;
                this.chunkOffset = 0;
                this.bufferedFrames = 0;
                this.primed = false;
                this.lastLeft = 0;
                this.lastRight = 0;
                this.fadeInFrames = 0;
                this.crossfadeFrames = 0;
                this.crossfadeLeft = 0;
                this.crossfadeRight = 0;
                this.callbacksSinceStats = 0;
                for (const key of Object.keys(this.stats)) this.stats[key] = 0;
                return;
            }
            if (event.data?.type === 'cue-rebase') {
                this.chunks.length = 0;
                this.chunkOffset = 0;
                this.bufferedFrames = 0;
                this.primed = false;
                this.fadeInFrames = 0;
                this.crossfadeFrames = 64;
                this.crossfadeLeft = this.lastLeft;
                this.crossfadeRight = this.lastRight;
                return;
            }
            if (event.data?.type === 'buffer-target') {
                const frames = event.data.frames;
                if (Number.isInteger(frames) && frames >= 128 && frames <= 16384)
                    this.primeTargetFrames = frames;
                return;
            }
            if (event.data?.type !== 'pcm') return;
            const pcm = event.data.pcm;
            if (!(pcm instanceof Int16Array) || pcm.length < 2) return;
            this.chunks.push(pcm);
            this.bufferedFrames += pcm.length / 2;
        };
    }

    readFrame() {
        while (this.chunks.length > 0) {
            const chunk = this.chunks[0];
            if (this.chunkOffset + 1 < chunk.length) {
                const frame = [chunk[this.chunkOffset], chunk[this.chunkOffset + 1]];
                this.chunkOffset += 2;
                this.bufferedFrames--;
                if (this.chunkOffset === chunk.length) {
                    this.chunks.shift();
                    this.chunkOffset = 0;
                }
                return frame;
            }
            this.chunks.shift();
            this.chunkOffset = 0;
        }
        return null;
    }

    process(_inputs, outputs) {
        const left = outputs[0][0];
        const right = outputs[0][1];
        left.fill(0);
        right.fill(0);
        /* The host selects a low-latency town target or the larger fight
         * cushion.  The fight VM can occupy the browser main thread for
         * longer than a town frame, so it retains ~85 ms at 48 kHz while
         * town dialog starts after only ~21 ms. */
        if (!this.primed && this.bufferedFrames >= this.primeTargetFrames) {
            this.primed = true;
            this.fadeInFrames = this.crossfadeFrames > 0 ? 0 : 64;
        }
        if (this.primed && this.bufferedFrames < left.length) this.primed = false;

        let delivered = 0;
        if (this.primed) {
            for (let i = 0; i < left.length; ++i) {
                const frame = this.readFrame();
                if (!frame) break;
                const sampleLeft = frame[0] / 32768;
                const sampleRight = frame[1] / 32768;
                if (this.crossfadeFrames > 0) {
                    const gain = (65 - this.crossfadeFrames) / 64;
                    left[i] = this.crossfadeLeft * (1 - gain) +
                        sampleLeft * gain;
                    right[i] = this.crossfadeRight * (1 - gain) +
                        sampleRight * gain;
                    this.crossfadeFrames--;
                } else {
                    const gain = this.fadeInFrames > 0
                        ? (65 - this.fadeInFrames) / 64 : 1;
                    left[i] = sampleLeft * gain;
                    right[i] = sampleRight * gain;
                    if (this.fadeInFrames > 0) this.fadeInFrames--;
                }
                this.lastLeft = left[i];
                this.lastRight = right[i];
                const peak = Math.max(Math.abs(frame[0]), Math.abs(frame[1]));
                this.stats.deliveredPeak = Math.max(this.stats.deliveredPeak, peak);
                this.stats.deliveredNonzero += frame[0] !== 0 || frame[1] !== 0 ? 1 : 0;
                delivered++;
            }
        } else if (this.lastLeft !== 0 || this.lastRight !== 0) {
            /* A delayed main-thread frame used to turn the final non-zero
             * sample directly into silence, producing an audible click or
             * short burst of static. Ramp the last sample to zero over half
             * an AudioWorklet block; re-priming is faded in above. */
            for (let i = 0; i < Math.min(64, left.length); ++i) {
                const gain = (63 - i) / 64;
                left[i] = this.lastLeft * gain;
                right[i] = this.lastRight * gain;
            }
            this.lastLeft = 0;
            this.lastRight = 0;
            this.crossfadeFrames = 0;
        }
        this.stats.callbacks++;
        this.stats.requestedFrames += left.length;
        this.stats.deliveredFrames += delivered;
        this.stats.underrunFrames += left.length - delivered;
        this.stats.bufferedFrames = this.bufferedFrames;
        if (++this.callbacksSinceStats >= 16) {
            this.callbacksSinceStats = 0;
            this.port.postMessage({ type: 'stats', stats: { ...this.stats } });
        }
        return true;
    }
}

registerProcessor('zeliard-pcm', ZeliardPcmProcessor);
