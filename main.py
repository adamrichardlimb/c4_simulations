import threading
from pytube import YouTube
import whisper


def download_video(url):
    yt = YouTube(url)
    video = yt.streams.filter(progressive=True, file_extension='mp4').order_by('resolution').desc().first()
    return video.download()


def process_video(url):
    video_path = download_video(url)
    print(f'Downloaded video {url}')


def thread_function(url):
    process_video(url)
    print("Finished processing.")


urls = ["https://www.youtube.com/watch?v=vc-ljzNLJBk",
        "https://www.youtube.com/watch?v=ddHN2qmvCG0",
        "https://www.youtube.com/watch?v=GNaWPV5l4j4",
        "https://www.youtube.com/watch?v=_Tc4bl1yZLw"]

threads = []
for url in urls:
    thread = threading.Thread(target=thread_function, args=(url,))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()
