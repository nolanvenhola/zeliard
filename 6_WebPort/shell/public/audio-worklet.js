class ZeliardPcmProcessor extends AudioWorkletProcessor {
    constructor() {
        super();
        this.chunks = [];
        this.chunkOffset = 0;
        this.bufferedFrames = 0;
        this.primed = false;
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
                this.callbacksSinceStats = 0;
                for (const key of Object.keys(this.stats)) this.stats[key] = 0;
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
        /* The fight VM can occupy the browser main thread for longer than a
         * town frame.  Keep ~85 ms at 48 kHz queued on the audio thread so
         * combat SFX do not underrun and repeatedly hard-restart as fuzz. */
        if (!this.primed && this.bufferedFrames >= 4096) this.primed = true;
        if (this.primed && this.bufferedFrames < left.length) this.primed = false;

        let delivered = 0;
        if (this.primed) {
            for (let i = 0; i < left.length; ++i) {
                const frame = this.readFrame();
                if (!frame) break;
                left[i] = frame[0] / 32768;
                right[i] = frame[1] / 32768;
                const peak = Math.max(Math.abs(frame[0]), Math.abs(frame[1]));
                this.stats.deliveredPeak = Math.max(this.stats.deliveredPeak, peak);
                this.stats.deliveredNonzero += frame[0] !== 0 || frame[1] !== 0 ? 1 : 0;
                delivered++;
            }
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
