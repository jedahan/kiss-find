window.addEventListener('load', () => {
  const headers = document.getElementById('header').children
  Array.from(headers).forEach((child, index) => {
    child.addEventListener('click', () => sortColumn(index))
  })
  previousColumn = null
})

function sortColumn(column) {
  const rows = Array.from(document.getElementById('sortable').rows)
  const columns = Array.from(document.getElementById('sortable').rows[0].cells)
  const arrayTable = rows.map((_) => Array(columns.length))

  rows.forEach((_, row) => {
    columns.forEach((_, column) => {
      arrayTable[row][column] =
        document.getElementById('sortable').rows[row].cells[column].innerHTML
    })
  })

  const thead = arrayTable.shift()

  if (previousColumn && column === previousColumn) {
    arrayTable.reverse()
  } else {
    arrayTable.sort((a, b) => {
      if (a[column] === b[column]) return 0
      if (a[column] < b[column]) return -1
      return 1
    })
  }

  previousColumn = column

  arrayTable.unshift(thead)

  rows.forEach((_, row) => {
    columns.forEach((_, column) => {
      document.getElementById('sortable').rows[row].cells[column].innerHTML =
        arrayTable[row][column]
    })
  })

  document.getElementsByTagName('input')[0].dispatchEvent(new Event('input'))
}
