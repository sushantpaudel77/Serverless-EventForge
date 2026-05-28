import { ArrowRight } from 'lucide-react';

export default function CreateForm({ newItem, setNewItem, onSubmit, creating }) {
  return (
    <div className="relative mb-20">
      <form
        onSubmit={onSubmit}
        className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-8"
      >
        <p className="text-xs font-mono tracking-[0.25em] uppercase text-blue-100/85 mb-3">
          New Item — 01
        </p>
        <h2 className="text-2xl font-bold text-white tracking-tight mb-7">
          Create something new
        </h2>

        {/* Always-visible row: flex on all sizes, wrap on small */}
        <div className="flex flex-wrap gap-3 items-center">
          <input
            type="text"
            placeholder="Name"
            value={newItem.name}
            onChange={(e) => setNewItem({ ...newItem, name: e.target.value })}
            required
            className="flex-1 min-w-[160px] px-4 py-3 rounded-xl text-sm outline-none transition-all
                       bg-white/12 border border-white/20 text-white placeholder:text-blue-100/70
                       focus:border-blue-200/60 focus:ring-2 focus:ring-blue-300/20"
          />
          <input
            type="text"
            placeholder="Description (optional)"
            value={newItem.description}
            onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
            className="flex-[2] min-w-[200px] px-4 py-3 rounded-xl text-sm outline-none transition-all
                       bg-white/12 border border-white/20 text-white placeholder:text-blue-100/70
                       focus:border-blue-200/60 focus:ring-2 focus:ring-blue-300/20"
          />
          <button
            type="submit"
            disabled={creating || !newItem.name.trim()}
            className="shrink-0 flex items-center gap-2 px-6 py-3 rounded-xl font-bold text-sm
                       bg-white text-blue-900 transition-all duration-200
                       hover:bg-blue-50 hover:shadow-lg hover:shadow-blue-950/40 hover:scale-[1.03]
                       disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:scale-100
                       whitespace-nowrap"
          >
            {creating ? 'Adding…' : 'Add Item'}
            <ArrowRight size={15} />
          </button>
        </div>
      </form>
    </div>
  );
}