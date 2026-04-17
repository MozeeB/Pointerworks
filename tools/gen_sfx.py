#!/usr/bin/env python3
"""Generate tiny sfxr-style WAV SFX + music loop for Pointerworks.

Outputs 44.1 kHz mono 16-bit WAVs. Small files, ~ms to kb range.
"""

import math
import os
import struct
import wave
from typing import Iterable


SR = 44100
BASE = "/Users/mujibnoctua/Documents/CikupProjects/machines-game/audio"


def write_wav(path: str, samples: Iterable[float]) -> None:
	os.makedirs(os.path.dirname(path), exist_ok=True)
	with wave.open(path, "wb") as w:
		w.setnchannels(1)
		w.setsampwidth(2)
		w.setframerate(SR)
		for s in samples:
			v = max(-1.0, min(1.0, s))
			w.writeframes(struct.pack("<h", int(v * 32000)))


def tone(duration: float, freq: float, shape: str = "sine", env: str = "decay",
		 vol: float = 0.5, pitch_slide: float = 0.0) -> Iterable[float]:
	n = int(SR * duration)
	for i in range(n):
		t = i / SR
		f = freq * (1.0 + pitch_slide * t)
		phase = (f * t) % 1.0
		if shape == "sine":
			s = math.sin(2 * math.pi * phase)
		elif shape == "square":
			s = 1.0 if phase < 0.5 else -1.0
		elif shape == "saw":
			s = 2.0 * phase - 1.0
		elif shape == "triangle":
			s = 4.0 * abs(phase - 0.5) - 1.0
		elif shape == "noise":
			import random
			s = random.uniform(-1.0, 1.0)
		else:
			s = 0.0
		# Envelope
		if env == "decay":
			e = max(0.0, 1.0 - i / n)
		elif env == "attack":
			e = min(1.0, i / max(1, int(0.01 * SR)))
		elif env == "ad":
			a = max(1, int(0.02 * SR))
			if i < a:
				e = i / a
			else:
				e = max(0.0, 1.0 - (i - a) / max(1, n - a))
		elif env == "flat":
			e = 1.0
		else:
			e = 1.0
		yield s * e * vol


def mix(*streams):
	iters = [iter(s) for s in streams]
	while True:
		total = 0.0
		alive = False
		for it in iters:
			v = next(it, None)
			if v is not None:
				total += v
				alive = True
		if not alive:
			return
		yield total


def concat(*streams):
	for s in streams:
		yield from s


def silence(duration: float):
	for _ in range(int(SR * duration)):
		yield 0.0


# spawn.wav — short high blip, rising pitch (cursor born)
def gen_spawn():
	return list(tone(0.12, 520, "square", "decay", 0.35, pitch_slide=0.8))


# deflect.wav — metallic clank: noise burst + square decay
def gen_deflect():
	noise = list(tone(0.04, 0, "noise", "decay", 0.4))
	body = list(tone(0.1, 180, "square", "decay", 0.35, pitch_slide=-0.5))
	out = []
	for i in range(max(len(noise), len(body))):
		a = noise[i] if i < len(noise) else 0.0
		b = body[i] if i < len(body) else 0.0
		out.append(a + b)
	return out


# hit_target.wav — pressure-release chime (two sine pops)
def gen_hit_target():
	a = list(tone(0.15, 660, "sine", "decay", 0.35))
	b = list(tone(0.2, 990, "sine", "decay", 0.3))
	combined = []
	for i in range(len(a)):
		combined.append(a[i])
	for i in range(len(b)):
		if i < len(combined):
			combined[i] += b[i]
		else:
			combined.append(b[i])
	return combined


# win.wav — 4-note ascending arpeggio (C E G C)
def gen_win():
	notes = [(523, 0.12), (659, 0.12), (784, 0.12), (1047, 0.3)]
	out = []
	for freq, dur in notes:
		out.extend(tone(dur, freq, "triangle", "ad", 0.4))
	return out


# place_part.wav — short low thunk
def gen_place_part():
	return list(tone(0.08, 220, "square", "decay", 0.45, pitch_slide=-0.4))


# factory_loop.wav — 20s industrial drone + rhythmic pulse
def gen_music_loop():
	duration = 20.0
	n = int(SR * duration)
	out = [0.0] * n
	# Base drone A2 + E3 (low)
	for i in range(n):
		t = i / SR
		drone = (
			0.08 * math.sin(2 * math.pi * 110 * t)
			+ 0.05 * math.sin(2 * math.pi * 164.81 * t)
			+ 0.04 * math.sin(2 * math.pi * 82.41 * t)  # A1 bass
		)
		# Slow LFO on drone
		lfo = 0.7 + 0.3 * math.sin(2 * math.pi * 0.2 * t)
		out[i] += drone * lfo
	# Rhythmic pulse every 0.5s — square chirp on offbeat, softer
	beat_period = 0.5
	beat_samples = int(SR * beat_period)
	for beat_start in range(0, n, beat_samples):
		# Short percussive tick: 0.03s square decay
		tick_len = int(SR * 0.03)
		for j in range(tick_len):
			idx = beat_start + j
			if idx >= n:
				break
			phase = (220 * (j / SR)) % 1.0
			s = 1.0 if phase < 0.5 else -1.0
			env = max(0.0, 1.0 - j / tick_len)
			out[idx] += s * env * 0.08
	# Mid-duration bell every 4 beats
	bell_period = 2.0
	bell_samples = int(SR * bell_period)
	for bell_start in range(0, n, bell_samples):
		bell_len = int(SR * 0.25)
		for j in range(bell_len):
			idx = bell_start + j
			if idx >= n:
				break
			t = j / SR
			s = math.sin(2 * math.pi * 659.25 * t)  # E5
			env = max(0.0, 1.0 - j / bell_len)
			out[idx] += s * env * 0.06
	return out


def main():
	write_wav(os.path.join(BASE, "sfx", "spawn.wav"), gen_spawn())
	write_wav(os.path.join(BASE, "sfx", "deflect.wav"), gen_deflect())
	write_wav(os.path.join(BASE, "sfx", "hit_target.wav"), gen_hit_target())
	write_wav(os.path.join(BASE, "sfx", "win.wav"), gen_win())
	write_wav(os.path.join(BASE, "sfx", "place_part.wav"), gen_place_part())
	write_wav(os.path.join(BASE, "music", "factory_loop.wav"), gen_music_loop())
	for f in [
		"sfx/spawn.wav",
		"sfx/deflect.wav",
		"sfx/hit_target.wav",
		"sfx/win.wav",
		"sfx/place_part.wav",
		"music/factory_loop.wav",
	]:
		p = os.path.join(BASE, f)
		print(f"{f}: {os.path.getsize(p)} bytes")


if __name__ == "__main__":
	main()
