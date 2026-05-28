import { useState, useEffect, useCallback } from 'react';
import { AlertCircle } from 'lucide-react';
import CreateForm from './components/CreateForm';
import ItemCard from './components/ItemCard';
import EditForm from './components/EditForm';

const API_URL = import.meta.env.VITE_API_URL;

export default function App() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newItem, setNewItem] = useState({ name: '', description: '' });
  const [creating, setCreating] = useState(false);
  const [editingId, setEditingId] = useState(null);

  /*  fetch  */
  const fetchItems = useCallback(async () => {
    try {
      setError(null);
      const res = await fetch(`${API_URL}/items`);
      if (!res.ok) throw new Error(`Server error ${res.status}`);
      const data = await res.json();
      data.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      setItems(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchItems();
  }, [fetchItems]);

  /* create  */
  const handleCreate = async (e) => {
    e.preventDefault();
    if (!newItem.name.trim()) return;
    try {
      setCreating(true);
      setError(null);
      const res = await fetch(`${API_URL}/items`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: newItem.name.trim(),
          description: newItem.description.trim(),
        }),
      });
      if (!res.ok) throw new Error(`Failed to create item (${res.status})`);
      setNewItem({ name: '', description: '' });
      await fetchItems();
    } catch (err) {
      setError(err.message);
    } finally {
      setCreating(false);
    }
  };

  /* update */
  const handleUpdate = async (id, data) => {
    try {
      setError(null);
      const res = await fetch(`${API_URL}/items/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!res.ok) throw new Error(`Failed to update item (${res.status})`);
      setEditingId(null);
      await fetchItems();
    } catch (err) {
      setError(err.message);
    }
  };

  /* delete  */
  const handleDelete = async (id) => {
    try {
      setError(null);
      const res = await fetch(`${API_URL}/items/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error(`Failed to delete item (${res.status})`);
      await fetchItems();
    } catch (err) {
      setError(err.message);
    }
  };

  /* render  */
  return (
    <div className="relative min-h-screen bg-gradient-to-tr from-zinc-950 via-blue-700 to-indigo-500/20 text-white overflow-x-hidden">
      {/* Grain texture */}
      <div
        style={{
          backgroundImage: 'url(/grain.svg)',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          mixBlendMode: 'overlay',
        }}
        className="absolute inset-0 bg-zinc-800 pointer-events-none opacity-50"
      />

      {/*  Hero  */}
      <header className="relative max-w-6xl mx-auto px-6 pt-24 pb-20">
        <p className="font-mono text-[11px] tracking-[0.3em] uppercase text-blue-100 mb-5">
          Workspace
        </p>

        <h1 className="text-6xl lg:text-8xl font-bold tracking-tighter leading-none text-white mb-6">
          Item
          <br />
          Manager
        </h1>

        <p className="text-lg lg:text-xl text-blue-100/80 max-w-md leading-relaxed font-light">
          Design studio that not only creates digital products but also
          experiences.
        </p>

        {/* Decorative rule */}
        <div className="mt-10 h-px w-24 bg-gradient-to-r from-white/40 to-transparent" />
      </header>

      {/* Main content  */}
      <main className="relative max-w-6xl mx-auto px-6 pb-24">
        {/* Error banner */}
        {error && (
          <div
            className="flex items-center gap-3 mb-10 px-5 py-4 rounded-xl text-sm
                          bg-red-500/10 border border-red-400/20 text-red-300 backdrop-blur-sm"
          >
            <AlertCircle size={15} className="shrink-0" />
            {error}
          </div>
        )}

        {/* Create form */}
        <CreateForm
          newItem={newItem}
          setNewItem={setNewItem}
          onSubmit={handleCreate}
          creating={creating}
        />

        {/* Items section */}
        <section>
          <div className="flex items-center gap-4 mb-8">
            <h2 className="text-2xl font-bold text-white tracking-tight">
              Items
            </h2>
            {!loading && (
              <span
                className="font-mono text-xs text-blue-200/40 border border-white/10
                               px-2.5 py-1 rounded-full"
              >
                {items.length}
              </span>
            )}
          </div>

          {loading ? (
            /* Loading dots */
            <div className="center-item py-32 gap-2">
              {[0, 1, 2].map((i) => (
                <div
                  key={i}
                  className="w-2 h-2 rounded-full bg-white/30 animate-pulse"
                  style={{ animationDelay: `${i * 0.18}s` }}
                />
              ))}
            </div>
          ) : items.length === 0 ? (
            <div className="center-item py-32">
              <p className="font-mono text-xs tracking-widest uppercase text-blue-200/30">
                No items yet — create one above
              </p>
            </div>
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
              {items.map((item) =>
                editingId === item.id ? (
                  <div
                    key={item.id}
                    className="bg-white/8 backdrop-blur-md border border-white/15 rounded-2xl p-6"
                  >
                    <EditForm
                      item={item}
                      onSave={(data) => handleUpdate(item.id, data)}
                      onCancel={() => setEditingId(null)}
                    />
                  </div>
                ) : (
                  <ItemCard
                    key={item.id}
                    item={item}
                    onEdit={setEditingId}
                    onDelete={handleDelete}
                  />
                )
              )}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
