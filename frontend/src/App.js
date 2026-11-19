import React, { useState, useEffect } from 'react';

function App() {
  const [ideas, setIdeas] = useState([]);
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(false);

  const fetchIdeas = async () => {
    try {
      const res = await fetch('/api/ideas');
      const data = await res.json();
      setIdeas(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error('Error fetching ideas:', err);
    }
  };

  useEffect(() => {
    fetchIdeas();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!content.trim()) return;
    setLoading(true);
    try {
      await fetch('/api/ideas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content }),
      });
      setContent('');
      fetchIdeas();
    } catch (err) {
      console.error('Error adding idea:', err);
    }
    setLoading(false);
  };

  return (
    <div style={{ maxWidth: '640px', margin: '40px auto', padding: '20px' }}>
      <h1 style={{ color: '#1a202c', textAlign: 'center' }}>💡 The Idea Board</h1>
      <p style={{ textAlign: 'center', color: '#4a5568' }}>
        Cloud-Agnostic Multi-Cloud DevOps Platform
      </p>

      <form onSubmit={handleSubmit} style={{ display: 'flex', gap: '10px', marginBottom: '24px' }}>
        <input
          type="text"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Share a brilliant idea..."
          style={{
            flex: 1,
            padding: '12px',
            borderRadius: '8px',
            border: '1px solid #cbd5e0',
            fontSize: '16px',
          }}
        />
        <button
          type="submit"
          disabled={loading}
          style={{
            padding: '12px 24px',
            backgroundColor: '#2563eb',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            cursor: 'pointer',
            fontWeight: 'bold',
          }}
        >
          {loading ? 'Posting...' : 'Add Idea'}
        </button>
      </form>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {ideas.length === 0 ? (
          <p style={{ textAlign: 'center', color: '#718096' }}>No ideas yet. Be the first!</p>
        ) : (
          ideas.map((idea) => (
            <div
              key={idea.id}
              style={{
                background: 'white',
                padding: '16px',
                borderRadius: '8px',
                boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
              }}
            >
              <p style={{ margin: '0 0 8px 0', fontSize: '16px', color: '#2d3748' }}>{idea.content}</p>
              <small style={{ color: '#a0aec0' }}>
                {new Date(idea.created_at).toLocaleString()}
              </small>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;