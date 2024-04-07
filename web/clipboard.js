async function getImage() {
  // get image from clipboard
  const contents = await navigator.clipboard.read()
  for (const item of contents) {
    if (item.types.includes('image/png')) {
      const blob = await item.getType('image/png')
      return blob
    }
  }
}

async function setImage(blob) {
  // set image to clipboard
  await navigator.clipboard.write([
    new ClipboardItem({
      'image/png': blob
    })
  ])
}
