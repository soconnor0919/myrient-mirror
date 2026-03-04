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
                    if value.startswith("?") or value.startswith("/") or value in ["./", "../"]:
                        continue
                    self.files.append(value)

def main():
    print("DEBUG: Manager script started")
    systems_raw = os.getenv("SYNC_SYSTEMS", "NES,SNES,GB,GBC,GBA,DS,GC,WII")
    systems = [s.strip() for s in systems_raw.split(",") if s.strip()]
    region_regex = os.getenv("REGION_FILTER", ".*\\(USA\\).*")
    
    print(f"DEBUG: Configured systems: {systems}")
    print(f"DEBUG: Region regex: {region_regex}")

    base_url = "https://myrient.erista.me/files"
    headers = {"User-Agent": "Mozilla/5.0"}
    
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

    queue_path = "/tmp/aria2.queue"
    match_count = 0
    
    with open(queue_path, "w") as f:
        for sys in systems:
            if sys not in paths:
                print(f"DEBUG: System {sys} not in path mapping, skipping")
                continue
            
            url = f"{base_url}/{paths[sys]}/"
            print(f"Crawling {sys}: {url}")
            try:
                r = requests.get(url, headers=headers)
                print(f"DEBUG: Status {r.status_code} for {sys}")
                parser = MyrientParser()
                parser.feed(r.text)
                
                sys_matches = 0
                for link in parser.files:
                    filename = urllib.parse.unquote(link)
                    if re.search(region_regex, filename):
                        f.write(f"{url}{link}\n")
                        f.write(f"  dir=/data/{sys}\n")
                        f.write(f"  out={filename}\n")
                        sys_matches += 1
                        match_count += 1
                print(f"DEBUG: Found {sys_matches} matches for {sys}")
            except Exception as e:
                print(f"DEBUG: ERROR crawling {sys}: {e}")

    print(f"DEBUG: Manager finished. Total matches in queue: {match_count}")

if __name__ == "__main__" :
    main()
