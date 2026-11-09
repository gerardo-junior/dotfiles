---
title: audio-watchdog — unattended audio health check
machine: artemis
service: audio
type: runbook
status: active
updated: 2026-11-03
---

# audio-watchdog

`audio-watchdog.timer` runs `audio-watchdog` every two minutes. It keeps the
audio graph usable without anyone watching it.

## What it checks

| Failure | Detection | Action |
|---|---|---|
| PipeWire control interface dead | `wpctl status` does not answer in 5s | restart `wireplumber pipewire pipewire-pulse` under a 45s timeout |
| Bluetooth A2DP path broken | delegated to `bt-recover --check` | controller power cycle, reconnect, restore the A2DP profile |

`bt-recover` lives in `~/.local/bin`. It is idempotent: on a healthy graph it
probes and exits without touching anything.

## Unattended rules

The timer runs without a terminal, so:

- nothing ever prompts for a password — the privileged `--full` path (re-creating
  the xHCI controller) is skipped and logged instead;
- a headset sitting on an HFP profile is treated as **in use** and left alone,
  so the watchdog cannot cut a call;
- after a failed attempt the next one waits ten minutes (`RECOVERY_COOLDOWN`);
- a power cycle is never left half-done: the adapter is only considered back
  when `bluetoothctl show` reports `Powered: yes`, and the script waits for
  WirePlumber to re-register the BlueZ endpoints before calling a card broken;
- syslog only gets a line when the outcome changes, not every two minutes;
- a `mkdir` lock keeps two invocations from overlapping.

## Manual use

```sh
bt-recover            # detect and fix (escalates light -> full)
bt-recover --check    # report only, exit 1 when not healthy
bt-recover --full     # force the privileged controller recovery
bt-recover --test     # play a tone after recovering
```

History and state live in `~/.local/state/bt-recover/`.

## Limits

- Losing the controller after a USB bus flap needs root. The timer cannot fix
  that; it logs `controller is down; privileged recovery required` and waits for
  `bt-recover --full`.
- The A2DP cache recovery is a workaround for a BlueZ bug, not a cure: it will
  keep happening occasionally until BlueZ handles stale remote SEPs properly.
- The FreeBuds Pro 5 drop the A2DP transport within minutes when negotiated with
  **AAC**, which is what used to feed the cache bug. `50-bluez-codecs.conf` pins
  the card to SBC/SBC-XQ; without it the recovery loop comes back.
