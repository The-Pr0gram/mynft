import json
import pathlib
from quote import quote


template = {
    "external_url": ...,
    "image": ...,
    "name": ...,
}

with open("cids", "r") as f:
    cids = f.read().split()


with open("cids", "r") as f:
    cids = f.read().split()


filenames = list(map(lambda x: x.name, pathlib.Path('dogs').glob('*.jpg')))

# res = quote("dog", limit=len(cids))
# print(res)

# quotes = [r["quote"] for r in res]


for i, (cid, filename) in enumerate(zip(cids, filenames)):
    template["image"] = f"ipfs://{cid}"
    template["name"] = filename
    template["external_url"] = f"https://nft.artopus.fun/{filename}"
    # template["description"] = q
    with open(f"./URIs/{i}", "w") as f:
        json.dump(template, f)
