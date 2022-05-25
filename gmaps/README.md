## GOOGLE MAPS API

### 5 Part Process to download, classify, and read in data

This process will just update the file `data_write/name_class.txt` and store classifed images in the appropriate folder.

Steps:

1. Make sure you pull the latest verstion of `data_write/name_class.txt`. Move all the images in Drive >> Data >> GoogleMaps >> temp >> classified_images to your cloned repo, also to the `classified_images` folder.


2. Use `download_images.ipynb` to download images using the google maps API. This will save them into the `source_images` folder.
You will need an API key for this.
* Log in to your Google Cloud console
* Under the hamburger menu go to APIs & Services >> +ENABLE APIS AND SERVICES. Add the Google Maps Static API
* Add an API key to your account, again by going to APIs & Services >> Credentials >> +CREATE Credentials
* Plug this API Key into the `API_KEY` variable in the notebook.

3. Use `move_classify.ipynb` to read in data from the `source_images` folder and append to the data file that stores the file name and classification (located in `data_write/`).

4. Use  `read_data.ipynb` to read in the data and classifications.

5. Copy all the images in your `classified_images` folder to the Google Drive Data folder (Drive >> Data >> GoogleMaps >> temp >> classified_images) and push the new version of the file `data_write/name_class.txt` to github.


Working Directory on your local machine or VM should be as follows:

```
|---classified_images/
|------.png files
|---write_data/
|------name_class.txt
|---source_images/
|---read_data.ipynb
|---move_classify.ipynb
|---download_images.ipynb
```
