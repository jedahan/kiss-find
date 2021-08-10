window.onload = function () {
  let queued = false
  const input = document.getElementsByTagName('input')[0]

  // update counts on idle
  input.addEventListener('input', () => {
    if (!queued) {
      queued = true
      requestIdleCallback(() => {
        const matches = document.getElementsByClassName('match')

        document.getElementById('count').textContent = matches.length

        document.getElementById('uniques').textContent = new Set(Array.from(document.getElementsByClassName('match'))
          .map(match => match.getElementsByClassName('name')?.[0]?.textContent))
          .size
        queued = false
      })
    }
  })

  // update rows instantly
  input.addEventListener('input', (event) => {
    const needle = event.target.value.trim().toLowerCase()

    Array.from(document.getElementsByTagName('tr')).forEach((element) => {
      const found =
        needle.length === 0 ||
        element.getElementsByClassName('name')?.[0]?.textContent.toLowerCase().includes(needle) ||
        element.getElementsByClassName('url')?.[0]?.textContent.toLowerCase().includes(needle) ||
        element.getElementsByClassName('description')?.[0]?.textContent.toLowerCase().includes(needle) ||
        Array.from(element.getElementsByTagName('a')).some(a => a.textContent.toLowerCase().includes(needle))
      element.className = found ? 'match' : 'hidden'
    })

  })
  input.className = ''
}
