
const RESOURCE_NAME = 'AQ-farmingv2'; // e.g., 'aq-farmingv2' if that's your folder

let state = {
  shopId: null,
  balance: 0,
  items: [], // [{ item, name, price, category, count }]
  potential: 0,
  largeSaleThreshold: 50, // show modal at or above this quantity
  pendingSale: null, // { item, name, count, priceTotal }
};

/* Utility: qb-inventory image path */
function qbImage(item) {
  return `nui://qb-inventory/html/images/${item}.png`;
}

/* UI hooks */
const app = document.getElementById('app');
const grid = document.getElementById('item-grid');
const balanceEl = document.getElementById('player-balance');
const potentialEl = document.getElementById('potential-earnings');
const titleEl = document.getElementById('market-title');

const modal = document.getElementById('confirm-modal');
const modalText = document.getElementById('confirm-text');
const modalOk = document.getElementById('confirm-ok');
const modalCancel = document.getElementById('confirm-cancel');

const toasts = document.getElementById('toast-container');

/* Toasts */
function showToast(type, text) {
  const el = document.createElement('div');
  el.className = `toast ${type}`;
  el.textContent = text;
  toasts.appendChild(el);
  setTimeout(() => {
    el.remove();
  }, 2500);
}

/* Potential earnings calculator (sums qty * price across visible cards) */
function updatePotential() {
  let total = 0;
  grid.querySelectorAll('.card').forEach(card => {
    const price = parseFloat(card.dataset.price || '0');
    const input = card.querySelector('input');
    const qty = parseInt(input.value || '0', 10);
    total += price * qty;
  });
  state.potential = Math.floor(total);
  potentialEl.textContent = `$${state.potential}`;
}

/* Render item cards; inputs start at 0 and clamp to inventory count */
function renderItems(items) {
  grid.innerHTML = '';
  items.forEach(entry => {
    const card = document.createElement('div');
    card.className = 'card';
    card.dataset.item = entry.item;
    card.dataset.name = entry.name;
    card.dataset.price = entry.price;
    card.dataset.category = entry.category;

    const media = document.createElement('div');
    media.className = 'media';
    const img = document.createElement('img');
    img.src = qbImage(entry.item);

    const nameEl = document.createElement('div');
    nameEl.className = 'name';
    nameEl.textContent = entry.name;

    const meta = document.createElement('div');
    meta.className = 'meta';
    const priceEl = document.createElement('div');
    priceEl.className = 'price';
    priceEl.textContent = `$${entry.price}/ea`;
    const haveEl = document.createElement('div');
    haveEl.textContent = `You have: ${entry.count}`;
    meta.append(priceEl, haveEl);

    const controls = document.createElement('div');
    controls.className = 'controls';

    const inputWrap = document.createElement('div');
    inputWrap.className = 'input-wrap';
    const input = document.createElement('input');
    input.type = 'number';
    input.min = '0';
    input.max = entry.count;   // bound to inventory
    input.value = '0';         // start at 0

    const stepper = document.createElement('div');
    stepper.className = 'stepper';
    const minus = document.createElement('button');
    minus.textContent = '-';
    const plus = document.createElement('button');
    plus.textContent = '+';

    minus.onclick = () => {
      input.value = Math.max(0, parseInt(input.value || '0', 10) - 1);
      updatePotential();
    };
    plus.onclick = () => {
      input.value = Math.min(entry.count, parseInt(input.value || '0', 10) + 1);
      updatePotential();
    };
    input.oninput = () => {
      const val = parseInt(input.value || '0', 10);
      if (isNaN(val)) {
        input.value = '0';
      } else {
        input.value = Math.min(entry.count, Math.max(0, val)).toString();
      }
      updatePotential();
    };

    stepper.append(minus, plus);
    inputWrap.append(input, stepper);

    const sellBtn = document.createElement('button');
    sellBtn.className = 'sell-btn';
    sellBtn.textContent = 'Sell';

    sellBtn.onclick = () => {
      const count = parseInt(input.value || '0', 10);
      if (count <= 0) {
        showToast('error', 'Enter a valid amount to sell.');
        return;
      }
      const total = count * entry.price;

      if (count >= state.largeSaleThreshold) {
        state.pendingSale = { item: entry.item, name: entry.name, count, priceTotal: total };
        modalText.textContent = `Sell ${count}x ${entry.name} for $${total}?`;
        modal.classList.remove('hidden');
        return;
      }
      triggerSell(entry.item, entry.name, count, entry.price, card, input, haveEl);
    };

    media.appendChild(img);
    controls.append(inputWrap, sellBtn);
    card.append(media, nameEl, meta, controls);
    grid.appendChild(card);
  });

  updatePotential();
}

/* Modal events */
modalCancel.onclick = () => {
  state.pendingSale = null;
  modal.classList.add('hidden');
};
modalOk.onclick = () => {
  if (!state.pendingSale) return;
  const p = state.pendingSale;
  // Find the card to update inventory UI after sell
  const card = [...grid.querySelectorAll('.card')].find(c => c.dataset.item === p.item);
  const input = card ? card.querySelector('input') : null;
  const haveEl = card ? card.querySelector('.meta').lastChild : null;
  triggerSell(p.item, p.name, p.count, Math.floor(p.priceTotal / p.count), card, input, haveEl);
  state.pendingSale = null;
  modal.classList.add('hidden');
};

/* Filters */
document.querySelectorAll('.filter').forEach(btn => {
  btn.onclick = () => {
    document.querySelectorAll('.filter').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const cat = btn.dataset.category;
    const filtered = cat === 'all' ? state.items : state.items.filter(i => i.category === cat);
    renderItems(filtered);
  };
});

/* Close button */
document.getElementById('close').addEventListener('click', () => {
  app.classList.add('hidden');
  // NUI callback to clear focus on client side
  fetch(`https://${RESOURCE_NAME}/close`, { method: 'POST' }).catch(() => {});
});

/* Trigger sell → NUI callback to client → server event */
function triggerSell(item, name, count, price, card, input, haveEl) {
  showToast('success', `Selling ${count}x ${name}...`);

  fetch(`https://${RESOURCE_NAME}/sellItem`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ shopId: state.shopId, item, price, count })
  })
  .then(() => {
    // Optimistic UI update: reduce local inventory count and reset input to 0
    if (card && input && haveEl) {
      const currentMax = parseInt(input.max || '0', 10);
      const newMax = Math.max(0, currentMax - count);
      input.max = newMax.toString();
      input.value = '0';
      haveEl.textContent = `You have: ${newMax}`;
      updatePotential();
    }
  })
  .catch(err => {
    console.error('sellItem failed:', err);
    showToast('error', 'Sell request failed.');
  });
}

/* Message from client to open UI and hydrate items/balance */
window.addEventListener('message', (evt) => {
  const data = evt.data;
  if (data.action === 'open') {
    state.shopId = data.shopId;
    state.balance = data.balance || 0;
    state.items = (data.items || []).map(it => ({
      item: it.item,
      name: it.name || it.item,
      price: it.price,
      category: it.category || 'misc',
      count: it.count || 0
    }));

    titleEl.textContent = data.title || '🌾Straw Hat Ranch🌾';
    balanceEl.textContent = `$${state.balance}`;
    app.classList.remove('hidden');

    renderItems(state.items);
  } else if (data.action === 'notify') {
    showToast(data.type || 'success', data.message || '');
  } else if (data.action === 'updateBalance') {
    state.balance = data.balance || state.balance;
    balanceEl.textContent = `$${state.balance}`;
  }
});

/* Optional: local preview data for designing in a browser (commented by default) */
const previewData = {
  action: 'open',
  title: '🌾Straw Hat Ranch🌾',
  balance: 1280,
  shopId: 'farm_shop_01',
  items: [
    { item: 'wheat', name: 'Wheat', price: 12, category: 'crops', count: 24 },
    { item: 'corn', name: 'Corn', price: 10, category: 'crops', count: 12 },
    { item: 'milk', name: 'Milk', price: 10, category: 'animal', count: 6 },
    { item: 'egg', name: 'Eggs', price: 8, category: 'animal', count: 18 },
    { item: 'herb', name: 'Herbs', price: 14, category: 'herbs', count: 9 },
    { item: 'seed_wheat', name: 'Wheat Seeds', price: 2, category: 'misc', count: 50 },
  ]
};
// Uncomment for browser testing outside FiveM:
// window.postMessage(previewData, '*');