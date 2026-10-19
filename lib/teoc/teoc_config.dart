/*
 * Teoc Launcher — configuración personal.
 *
 * Este es el archivo para editar a mano: perfiles, ciudad del clima,
 * temas de noticias, mascota y proyectos.
 *
 * Los recordatorios y el calendario gamer NO están aquí: viven en
 * teoc/contenido.json del repositorio, y la tele los descarga sola.
 * Así los puedes editar desde el celular sin recompilar.
 */

class TeocProject {
  final String name;
  final String description;
  final String url;

  const TeocProject(this.name, this.description, this.url);
}

class TeocProfile {
  final String id;
  final String name;
  /// Paleta e ícono iniciales (se cambian desde la tele en "Personalizar").
  /// Paletas: noche, bosque, oceano, brasa, algodon, menta, lavanda, durazno.
  /// Íconos: orbe, monstruo, gato, fantasma, hongo, estrella, corazon, slime.
  final String defaultPalette;
  final String defaultAvatar;
  /// Signo zodiacal en minúsculas y sin tilde (ej: "escorpio"), o null.
  final String? zodiacSign;
  /// Temas de noticias (búsquedas en Google Noticias).
  final List<String> newsTopics;
  /// Apps favoritas por defecto (se pueden cambiar desde la tele).
  final List<String> defaultFavorites;

  const TeocProfile({
    required this.id,
    required this.name,
    required this.defaultPalette,
    required this.defaultAvatar,
    required this.newsTopics,
    required this.defaultFavorites,
    this.zodiacSign,
  });
}

class TeocConfig {
  /// Nombre de la empresa que aparece en el dispositivo de proyectos.
  static const String companyName = "Digital Monster";

  /// Nombre de la mascota pixel que vive en la pantalla de inicio.
  static const String mascotName = "Mon";

  /// Ciudad y coordenadas para el clima (Open-Meteo, sin API key).
  static const String weatherCityName = "Santiago";
  static const double weatherLatitude = -33.45;
  static const double weatherLongitude = -70.66;

  /// Contenido editable desde GitHub (recordatorios, calendario gamer, eventos).
  static const String remoteContentUrl =
      "https://raw.githubusercontent.com/TeocHub/flauncher/master/teoc/contenido.json";

  /// Minutos sin tocar el control antes de entrar al modo ambiente.
  static const int ambientAfterMinutes = 5;

  /// Horas fuera del launcher tras las cuales vuelve a preguntar "¿Quién está viendo?".
  static const int askProfileAfterHours = 3;

  static const List<TeocProfile> profiles = [
    TeocProfile(
      id: "teoc",
      name: "Teoc",
      defaultPalette: "noche",
      defaultAvatar: "orbe",
      zodiacSign: null,
      newsTopics: [
        "inteligencia artificial",
        "videojuegos",
        "educación Chile",
        "ciencia",
        "política Chile",
      ],
      defaultFavorites: [
        "com.amazon.amazonvideo.livingroom",
        "com.google.android.youtube.tv",
        "com.spotify.tv.android",
      ],
    ),
    TeocProfile(
      id: "skynook",
      name: "Skynook",
      defaultPalette: "algodon",
      defaultAvatar: "monstruo",
      zodiacSign: null,
      newsTopics: [
        "videojuegos",
        "tecnología",
        "Nintendo",
      ],
      defaultFavorites: [
        "com.amazon.amazonvideo.livingroom",
        "com.google.android.youtube.tv",
        "com.spotify.tv.android",
      ],
    ),
  ];

  /// Proyectos que se abren desde el dispositivo Digital Monster.
  static const List<TeocProject> projects = [
    TeocProject(
      "Portafolio",
      "Pedagogía, código, esoterismo e historias",
      "https://teochub.github.io/portfolio/",
    ),
    TeocProject(
      "FNAF Quest",
      "El cuestionario definitivo de FNAF",
      "https://teochub.github.io/fnaf-quest/",
    ),
  ];
}
