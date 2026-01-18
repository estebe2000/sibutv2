import React, { useEffect, useState } from 'react';
import { useStore } from '../store/useStore';
import { odooService } from '../services/odoo.service';

const OdooWidget = () => {
  const user = useStore((state) => state.user);
  const [status, setStatus] = useState<'loading' | 'missing' | 'ready' | 'provisioning'>('loading');
  const [dbName, setDbName] = useState('');
  const [error, setError] = useState('');

  const getExpectedDbName = (email: string) => {
    if (!email) return '';
    const name = email.split('@')[0];
    return name.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/^-|-$/g, '');
  };

  useEffect(() => {
    checkStatus();
  }, [user]);

  const checkStatus = async () => {
    if (!user?.email) return;
    
    try {
      setStatus('loading');
      const expectedDb = getExpectedDbName(user.email);
      setDbName(expectedDb);

      const dbs = await odooService.listDatabases();
      
      if (dbs.includes(expectedDb)) {
        setStatus('ready');
      } else {
        setStatus('missing');
      }
    } catch (err) {
      console.error(err);
      // Si on n'arrive pas à lister (ex: pas admin), on ne peut pas savoir.
      // Mais dans notre contexte, l'API list est peut-être restreinte ?
      // Pour l'instant l'API /list n'a pas de restriction de rôle dans le code python.
      setError("Impossible de vérifier l'état Odoo.");
      setStatus('missing'); 
    }
  };

  const handleProvision = async () => {
    if (!user?.email) return;
    
    try {
      setStatus('provisioning');
      await odooService.provision(user.email, "admin");
      
      // Petit délai pour laisser le temps à l'API de répondre (même si c'est async)
      setTimeout(() => {
        // En vrai il faudrait poller jusqu'à ce que ce soit prêt
        checkStatus();
      }, 5000); 
      
    } catch (err) {
      setError("Erreur lors de la création.");
      setStatus('missing');
    }
  };

  if (!user) return null;

  return (
    <div className="card shadow-sm mb-4">
      <div className="card-header bg-primary text-white d-flex justify-content-between align-items-center">
        <h5 className="mb-0">Mon Espace ERP (Odoo)</h5>
        <span className="badge bg-light text-dark">V17 Enterprise</span>
      </div>
      <div className="card-body text-center">
        {status === 'loading' && <div className="spinner-border text-primary" role="status"></div>}
        
        {status === 'missing' && (
            <div>
                <p>Vous n'avez pas encore d'environnement Odoo personnel.</p>
                <button className="btn btn-success btn-lg" onClick={handleProvision}>
                    🚀 Activer mon Odoo
                </button>
                {error && <div className="alert alert-danger mt-2">{error}</div>}
            </div>
        )}

        {status === 'provisioning' && (
            <div>
                <div className="spinner-border text-warning mb-3" role="status"></div>
                <p>Création de votre environnement en cours... (Cela peut prendre 1 minute)</p>
            </div>
        )}

        {status === 'ready' && (
            <div>
                <div className="alert alert-success">
                    <strong>Votre environnement est prêt !</strong>
                </div>
                <p className="mb-4">
                    Base de données : <code>{dbName}</code><br/>
                    Identifiants initiaux : <code>admin / admin</code>
                </p>
                <a 
                    href={`https://${dbName}.educ-ai.fr`} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="btn btn-primary btn-lg"
                >
                    Accéder à mon Odoo
                </a>
            </div>
        )}
      </div>
    </div>
  );
};

export default OdooWidget;
