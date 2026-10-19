/*
 * Teoc Launcher — configuración personal.
 *
 * Este es el archivo para editar a mano: tu nombre, la ciudad del clima
 * y la lista de proyectos que aparece en el Teoc-Vice.
 */

class TeocProject {
  final String name;
  final String description;
  final String url;

  const TeocProject(this.name, this.description, this.url);
}

class TeocConfig {
  /// Nombre con el que te saluda la pantalla de inicio.
  static const String userName = "Teoc";

  /// Ciudad y coordenadas para el clima (Open-Meteo, sin API key).
  static const String weatherCityName = "Santiago";
  static const double weatherLatitude = -33.45;
  static const double weatherLongitude = -70.66;

  /// Proyectos que se abren desde el Teoc-Vice.
  /// Para agregar uno nuevo, copia una línea y cambia nombre, descripción y URL.
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
