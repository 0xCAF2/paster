/** Get image from clipboard */
async function getImage() {
  const contents = await navigator.clipboard.read()
  for (const item of contents) {
    if (item.types.includes('image/png')) {
      const blob = await item.getType('image/png')
      return blob
    }
  }
}

/** Set image to clipboard */
async function setImage(blob) {
  await navigator.clipboard.write([
    new ClipboardItem({
      'image/png': blob
    })
  ])
}
