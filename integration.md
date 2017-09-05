# Poplar Integration

This page cover all the things related with the integration of Aspen project, mostly focus on kernel and user space HAL. It will over test cases, known issues, how to report issue, capture logs, etc.

It's not our intention here to provide a full set of test cases to validate a android product. Rather the goal here is provide minimal test cases and steps that can be used to 1) validate the basic kernel interfaces, when we doubt something might be wrong with the kernel; 2) validate the basic features from user's point of view such as play a youtube video.

We will keep it simple but useful.

## Test Video/Video

### 1.1 Unit Test audio

1. on the host
Download any .wav file, call it `test_audio.wav`.
adb push test_audio.wav /sdcard/test.wav

2. on poplar console, after board booting up
```
# tinyplay /sdcard/test.wav
Playing sample: 2 ch, 44100 hz, 16 bit
```

What to Expect:

You should hear the audio in both HDMI and audio line out interface.

### 1.2 test local media playback

1. Download the one of mp4 video from [1], call it `test_video.mp4`

2. (host) `adb push test_video.mp4 /sdcard/test.mp4`

3. Reboot the poplar board to make sure the new pushed media will be picked by the media player apps.

4. Plug in usb mouse (make sure your kernel has patch made ehci controller builtin)

4. Open Gallery app, click the video

What to Expect:

You should see the video playing and hear the audio in both HDMI and audio line out interface.

[1]http://www.mobiles24.co/downloads/tag/the+simpsons/mp4-videos

### 1.3 Test web media playback

1. Open web browser, to make sure we're testing the same video, type https://goo.gl/o8ErmS, which is `Taylor Swift - Look What You Made Me Do` in youtube.

What to Expect:

You should see the video playing and hear the audio in both HDMI and audio lineout interface.

## Test Graphics

## Test Wifi

## Test BlueTooth

## Known Issues

- audio: audio line out isn't configured correctly at the moment, waiting kernel patch.

## Report Issues

### Capture logs

General Preparation:

- power on the board, and it will stop at the u-boot console
- set up the serial tool, the instruction depend on the serial console tool you used. for minicom, `ctrl-A`, then `L`, then the log file name.
- boot android, either using `run setupa; run boota` or `run bootai`

For start up issues:

- Waiting android booting, *as soon as* you can get the console, type `logcat`, wait the log dumping (may take ~10 seconds), `ctrl+c` to kill the `logcat`
- type `ps` to get all the running process.

For specific issues:

- start logcat and make sure the log is captured
- reproduce the issue
- send the logcat information for analysis

It is always a good idea to provide the start up logs as well to make sure the issue isn't caused in early phase (case study: not able the get dhcp address is due to mounting failure in data partition).

