let state = { storeId: null, whitelist: [], imgRoot: '', total: 0 };

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'open') {
    state.storeId = data.storeId;
    state.whitelist = data.whitelist || [];
    state.imgRoot = data.imgRoot || '';
    render();
    document.getElementById('app').classList.remove('hidden');
  }
  if (data.action === 'saleResult') {
    state.total = 0;
    document.getElementById('totalLabel').textContent = 'Total: $0';
  }
});

function render() {
  const items = document.getElementById('items');
  items.innerHTML = '';
  state.whitelist.forEach(w => {
    const card = document.createElement('div');
    card.className = 'card';

    const img = document.createElement('img');
    img.src = `${state.imgRoot}${w.item}.png`;

    const row = document.createElement('div');
    row.className = 'row';

    const label = document.createElement('div');
    label.textContent = `${w.item} ($${w.price})`;

    const qty = document.createElement('input');
    qty.type = 'number';
    qty.min = '0';
    qty.value = '0';
    qty.dataset.item = w.item;
    qty.addEventListener('input', () => updateTotal());

    card.appendChild(img);
    card.appendChild(row);
    row.appendChild(label);
    row.appendChild(qty);
    items.appendChild(card);
  });
}

function updateTotal() {
  let total = 0;
  document.querySelectorAll('input[type="number"]').forEach(input => {
    const qty = parseInt(input.value, 10) || 0;
    const item = state.whitelist.find(w => w.item === input.dataset.item);
    if (item) total += qty * item.price;
  });
  state.total = total;
  document.getElementById('totalLabel').textContent = `Total: $${total}`;
}

document.getElementById('close').addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', body: '{}' });
  document.getElementById('app').classList.add('hidden');
});

document.getElementById('sell').addEventListener('click', () => {
  const items = [];
  document.querySelectorAll('input[type="number"]').forEach(input => {
    const qty = parseInt(input.value, 10) || 0;
    if (qty > 0) items.push({ item: input.dataset.item, qty });
  });
  fetch(`https://${GetParentResourceName()}/sellItems`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ storeId: state.storeId, items })
  });
});