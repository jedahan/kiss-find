window.onload = function () {
  const input = document.getElementsByTagName('input')[0]
  input.oninput = (event) => {
    const needle = event.target.value.trim()

    Array.from(document.getElementsByTagName('tr')).forEach((element) => {
      const found =
        needle.length === 0 ||
        element.firstChild.textContent.includes(needle) ||
        element.children[2].textContent.includes(needle) ||
        element.lastChild.textContent.includes(needle)
      element.className = found ? '' : 'hidden'
    })
  }
  input.className = ''
}
