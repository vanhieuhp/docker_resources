docker run --rm -it \
  -v $(pwd):/config \
  linuxserver/ffmpeg \
  -i /config/input.mkv \
  -c:v libx264 \
  -b:v 4M \
  -vf scale=1280:720 \
  -c:a copy \
  /config/output.mkv


1. 
```
 ffmpeg -i filename.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls filename.m3u8
```
-codec: copy
-c:v libx264 -crf 17 
test: 
docker run --rm --name ffmpeg -v ./data:/config linuxserver/ffmpeg:6.1.1 -i config/video_size_20.webm  -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls config/video_size_20.m3u8

