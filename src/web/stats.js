window.addEventListener('load', () => {
  const maintainers = new Set(
    Array.from(document.getElementsByClassName('maintainer')).map((element) => element.textContent)
  ).size
  document.getElementById('maintainerHeader').textContent += ` (${maintainers})`

  const uris = new Set(
    Array.from(document.getElementsByClassName('uri')).map((element) => element.textContent)
  ).size

  document.getElementById('urlHeader').textContent += ` (${uris})`
})
