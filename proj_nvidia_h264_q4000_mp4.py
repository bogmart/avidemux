#PY  <- Needed to identify #
#--automatically built--
# avidemux.2.7.1_x64

adm = Avidemux()
adm.videoCodec("ffNvEnc", "preset=2", "profile=3", "gopsize=100", "bframes=0", "bitrate=4000", "max_bitrate=8000")
adm.addVideoFilter("lavdeint", "deintType=5", "autoLevel=True")
adm.audioClearTracks()
adm.audioAddTrack(0)
adm.audioCodec(0, "LavAAC", "bitrate=128");
adm.audioSetDrc(0, 0)
adm.audioSetShift(0, 0,0)
adm.setContainer("MP4", "muxerType=0", "useAlternateMp3Tag=False", "forceAspectRatio=True", "aspectRatio=1")
