import { useState } from 'react';
import { Check, X } from 'lucide-react';

export default function EditForm({ item, onSave, onCancel }) {
  const [name, setName] = useState(item.name);
  const [description, setDescription] = useState(item.description || '');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) return;
    onSave({ name: name.trim(), description: description.trim() });
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <input
        type="text"
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Name"
        required
        autoFocus
        className="w-full px-4 py-2.5 rounded-lg text-sm outline-none transition-all
                   bg-white/12 border border-white/20 text-white placeholder:text-blue-100/70
                   focus:border-blue-300/60 focus:ring-2 focus:ring-blue-300/20"
      />
      <input
        type="text"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        placeholder="Description (optional)"
        className="w-full px-4 py-2.5 rounded-lg text-sm outline-none transition-all
                   bg-white/12 border border-white/20 text-white placeholder:text-blue-100/70
                   focus:border-blue-300/60 focus:ring-2 focus:ring-blue-300/20"
      />
      <div className="flex gap-2 pt-1">
        <button
          type="submit"
          className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all
                     bg-emerald-400/10 text-emerald-300 border border-emerald-400/25
                     hover:bg-emerald-400/20 hover:border-emerald-400/40"
        >
          <Check size={13} />
          Save
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all
                     text-blue-100/85 border border-white/20 hover:bg-white/12 hover:text-white"
        >
          <X size={13} />
          Cancel
        </button>
      </div>
    </form>
  );
}