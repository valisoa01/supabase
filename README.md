# NextFlutter App — Application Flutter connectée à un backend réel

Application Flutter full-stack utilisant **Supabase** pour l'authentification et **JSONPlaceholder** pour l'affichage de données REST. Architecture **Clean Architecture** (data/domain/presentation) avec persistance locale via **Hive** et mode hors-ligne.

---

## Architecture du projet

```
lib/
├── core/
│   ├── constants/
│   │   └── supabase_config.dart       # Configuration Supabase (via .env)
│   ├── error/
│   │   └── app_exception.dart         # Exceptions métier (Network, Server, Cache, Auth)
│   ├── network/
│   │   ├── auth_interceptor.dart       # Intercepteur Dio: injection JWT + refresh token
│   │   ├── dio_client.dart            # Client HTTP centralisé (restDio + authDio)
│   │   └── network_info.dart          # Vérification connectivité (connectivity_plus)
│   └── storage/
│       └── token_storage.dart         # Stockage sécurisé des tokens JWT
├── features/
│   ├── auth/                          # Authentification (login/register/logout)
│   │   ├── data/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   └── auth_repository.dart
│   │   └── presentation/
│   │       ├── auth_providers.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart       # Écran principal avec navigation + déconnexion
│   └── posts/                         # Feature Articles (3 écrans REST API)
│       ├── data/
│       │   ├── post_remote_datasource.dart
│       │   ├── post_local_datasource.dart   # Cache Hive
│       │   └── post_repository_impl.dart    # Logique online/offline
│       ├── domain/
│       │   ├── post.dart
│       │   └── post_repository.dart
│       └── presentation/
│           ├── post_providers.dart
│           ├── post_list_screen.dart        # Écran 1: Liste des articles
│           ├── post_detail_screen.dart      # Écran 2: Détail d'un article
│           └── create_post_screen.dart      # Écran 3: Création d'un article
└── main.dart
```

### Principe Clean Architecture

| Couche | Rôle |
|--------|------|
| **Domain** | Entités et abstractions (interfaces de repositories) |
| **Data** | Implémentations concrètes (data sources distantes + locales) |
| **Presentation** | UI Flutter + providers Riverpod |

---

## APIs utilisées

| API | Usage | Auth |
|-----|-------|------|
| **Supabase Auth** (`/auth/v1`) | Login, register, logout, refresh token | JWT (Bearer token) |
| **JSONPlaceholder** (`jsonplaceholder.typicode.com`) | Affichage, détail et création d'articles | Aucune |

---

## Fonctionnalités

- **Authentification** : Login / Register / Logout avec JWT (Supabase)
- **Refresh token** automatique via `AuthInterceptor`
- **3 écrans de données REST** : Liste, Détail, Création d'articles
- **Cache local Hive** : Les données sont persistées localement
- **Mode hors-ligne** : Affichage des données cachées quand le réseau est indisponible
- **Gestion d'erreurs réseau** : Messages utilisateur contextuels (pas de connexion, timeout, erreurs serveur)
- **Interface Material 3** avec navigation par onglets

---

## Configuration du projet

### 1. Cloner le repository

```bash
git clone <url-du-repo>
cd supabase
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer les variables d'environnement

Copier le fichier `.env.example` en `.env` :

```bash
cp .env.example .env
```

Puis modifier `.env` avec vos propres clés Supabase :

```
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-cle-anon
```

### 4. Lancer l'application

```bash
flutter run
```

---

## Tests

Exécuter tous les tests :

```bash
flutter test
```

Tests unitaires implémentés :

| Test | Couche | Description |
|------|--------|-------------|
| `auth_repository_impl_test.dart` | Auth Data | Login sauvegarde les tokens, register gère les cas, logout clearing |
| `post_repository_impl_test.dart` | Posts Data | Online/offline, cache, erreurs serveur, création |
| `post_local_datasource_test.dart` | Posts Data | Cache Hive : lecture, écriture, mise à jour, suppression |

---

## Dépendances principales

| Package | Version | Usage |
|---------|---------|-------|
| `flutter_riverpod` | ^3.4.3 | State management + DI |
| `dio` | ^5.11.1 | Client HTTP |
| `hive` / `hive_flutter` | ^2.2.3 | Cache local |
| `flutter_secure_storage` | ^11.1.1 | Stockage JWT sécurisé |
| `connectivity_plus` | ^7.3.1 | Détection réseau |
| `flutter_dotenv` | ^5.2.0 | Variables d'environnement |
| `mockito` | ^5.4.4 | Mocking pour tests |

---

## CI/CD

Pipeline GitHub Actions configuré dans `.github/workflows/ci.yml` :
- Analyse statique (`flutter analyze`)
- Tests unitaires (`flutter test`)
- Vérification de la compilation (`flutter build`)

---

## Structure des routes

| Route | Écran | Description |
|-------|-------|-------------|
| `/login` | LoginScreen | Page de connexion |
| `/register` | RegisterScreen | Page d'inscription |
| `/home` | HomeScreen | Page principale avec onglets (Articles + Profil) |
