import { useState } from 'react';
import { Edit2, Trash2 } from 'lucide-react';
import { formatDate, formatTime } from '../utils/Helpers';

export default function ItemCard({ item, onEdit, onDelete }) {
  const [deleting, setDeleting] = useState(false);

  const handleDelete = async () => {
    if (!window.confirm(`Delete "${item.name}"?`)) return;
    setDeleting(true);
    await onDelete(item.id);
    setDeleting(false);
  };

  return (
    <div
      className="group relative rounded-2xl p-6 overflow-hidden transition-all duration-300
                 bg-white/10 border border-white/20 backdrop-blur-md
                 hover:bg-white/15 hover:border-blue-200/40 hover:-translate-y-1 hover:shadow-xl
                 hover:shadow-blue-900/30"
    >
      {/* Shimmer on hover */}
      <div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500
                   bg-gradient-to-br from-blue-400/10 via-transparent to-indigo-400/10 rounded-2xl"
      />

      {/* Dot accent */}
      <div className="absolute top-5 right-5 w-1.5 h-1.5 rounded-full bg-blue-400/60 group-hover:bg-blue-300 transition-colors" />

      <div className="relative">
        <h3 className="text-base font-semibold text-white tracking-tight mb-1.5 leading-snug">
          {item.name}
        </h3>
        {item.description ? (
          <p className="text-sm text-blue-100/85 leading-relaxed mb-5">{item.description}</p>
        ) : (
          <p className="text-sm text-white/65 italic mb-5">No description</p>
        )}

        <div className="flex items-center justify-between pt-4 border-t border-white/10">
          <span className="text-[10px] font-mono text-blue-100/80 uppercase tracking-wider">
            {formatDate(item.createdAt)} · {formatTime(item.createdAt)}
          </span>
          <div className="flex gap-2">
            <button
              onClick={() => onEdit(item.id)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all
                         text-blue-100/90 border border-white/20
                         hover:text-white hover:border-blue-200/50 hover:bg-blue-400/15"
            >
              <Edit2 size={11} />
              Edit
            </button>
            <button
              onClick={handleDelete}
              disabled={deleting}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all
                         text-red-200/90 border border-transparent
                         hover:text-red-200 hover:border-red-300/35 hover:bg-red-400/12
                         disabled:opacity-40"
            >
              <Trash2 size={11} />
              {deleting ? '...' : 'Delete'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
