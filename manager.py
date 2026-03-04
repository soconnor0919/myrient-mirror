import os, re, requests, urllib.parse
from html.parser import HTMLParser

class MyrientParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.files = []
    def handle_starttag(self, tag, attrs):
        if tag == "a":
            for name, value in attrs:
                if name == "href":
                    # Myrient links are relative
                    # Ignore navigation and root links
                    if value.startswith("?") or value.startswith("/") or value in ["./", "../"]:
                        continue
                    self.files.append(value)

def main():
    systems = os.getenv("SYNC_SYSTEMS", "NES,SNES,GB,GBC,GBA,DS,GC,WII").split(",")
    region_regex = os.getenv("REGION_FILTER", ".*\\(USA\\).*")
    base_url = "https://myrient.erista.me/files"
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36"}
    paths = {
        "NES": "No-Intro/Nintendo - Nintendo Entertainment System (Headerless)",
        "SNES": "No-Intro/Nintendo - Super Nintendo Entertainment System",
        "N64": "No-Intro/Nintendo - Nintendo 64 (BigEndian)",
        "GB": "No-Intro/Nintendo - Game Boy",
        "GBC": "No-Intro/Nintendo - Game Boy Color",
        "GBA": "No-Intro/Nintendo - Game Boy Advance",
        "DS": "No-Intro/Nintendo - Nintendo DS (Decrypted)",
        "GC": "Redump/Nintendo - GameCube - NKit RVZ [zstd-19-128k]",
        "WII": "Redump/Nintendo - Wii - NKit RVZ [zstd-19-128k]"
    }
    with open("/tmp/aria2.queue", "w") as f:
        for sys in systems:
            sys = sys.strip()
            if sys not in paths: continue
            url = f"{base_url}/{paths[sys]}/"
            print(f"Crawling {sys}...")
            try:
                r = requests.get(url, headers=headers)
                parser = MyrientParser()
                parser.feed(r.text)
                # Remove duplicates while preserving order
                unique_links = []
                for link in parser.files:
                    if link not in unique_links: unique_links.append(link)
                
                for link in unique_links:
                    filename = urllib.parse.unquote(link)
                    if re.search(region_regex, filename):
                        f.write(f"{url}{link}\n  dir=/data/{sys}\n  out={filename}\n")
            except Exception as e:
                print(f"Error crawling {sys}: {e}")

if __name__ == "__main__":
    main()
