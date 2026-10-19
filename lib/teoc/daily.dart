/*
 * Teoc Launcher — contenido diario local: carta de tarot, consejo y energía astral.
 * Todo se calcula en la tele (no necesita internet) y cambia una vez al día por perfil.
 */

import 'weather.dart';

int _dailySeed(String profileId, DateTime date, int salt) {
  final key = "$profileId-${date.year}-${date.month}-${date.day}-$salt";
  int hash = 7;
  for (final unit in key.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

class TarotCard {
  final String numeral;
  final String name;
  final String symbol;
  final String meaning;
  final String advice;

  const TarotCard(this.numeral, this.name, this.symbol, this.meaning, this.advice);

  static TarotCard ofDay(String profileId, DateTime date) =>
      majorArcana[_dailySeed(profileId, date, 1) % majorArcana.length];
}

const List<TarotCard> majorArcana = [
  TarotCard("0", "El Loco", "✧", "Comienzos, libertad y salto de fe.",
      "Prueba algo nuevo sin esperar a tenerlo todo resuelto."),
  TarotCard("I", "El Mago", "∞", "Voluntad, talento y herramientas a mano.",
      "Ya tienes lo necesario: úsalo hoy."),
  TarotCard("II", "La Sacerdotisa", "☾", "Intuición, misterio y saber interior.",
      "Escucha esa corazonada antes de decidir."),
  TarotCard("III", "La Emperatriz", "❀", "Abundancia, creatividad y cuidado.",
      "Dedica tiempo a crear algo con calma."),
  TarotCard("IV", "El Emperador", "♜", "Estructura, orden y liderazgo.",
      "Ordena una cosa pendiente y sentirás el alivio."),
  TarotCard("V", "El Hierofante", "⚷", "Tradición, aprendizaje y guía.",
      "Aprende de alguien con más experiencia."),
  TarotCard("VI", "Los Enamorados", "♡", "Vínculos, elección y armonía.",
      "Elige desde lo que valoras, no desde el miedo."),
  TarotCard("VII", "El Carro", "➶", "Avance, determinación y victoria.",
      "Mantén el rumbo aunque haya baches."),
  TarotCard("VIII", "La Fuerza", "♌", "Valentía tranquila y paciencia.",
      "La suavidad también es fuerza."),
  TarotCard("IX", "El Ermitaño", "✦", "Introspección, pausa y sabiduría.",
      "Regálate un rato de silencio."),
  TarotCard("X", "La Rueda", "☸", "Ciclos, cambio y oportunidades.",
      "Lo que hoy gira, mañana se acomoda."),
  TarotCard("XI", "La Justicia", "⚖", "Equilibrio, verdad y consecuencias.",
      "Sé honesto contigo y con los demás."),
  TarotCard("XII", "El Colgado", "⟁", "Otra perspectiva y entrega.",
      "Mira el problema desde otro ángulo."),
  TarotCard("XIII", "La Muerte", "✝", "Transformación y cierre de ciclos.",
      "Suelta lo que ya cumplió su función."),
  TarotCard("XIV", "La Templanza", "⚗", "Balance, paciencia y mezcla justa.",
      "Ni todo ni nada: busca el punto medio."),
  TarotCard("XV", "El Diablo", "⛧", "Ataduras, deseos y hábitos.",
      "Revisa qué hábito te está quitando energía."),
  TarotCard("XVI", "La Torre", "⚡", "Sacudón, revelación y cambio brusco.",
      "Lo inesperado puede abrir espacio a algo mejor."),
  TarotCard("XVII", "La Estrella", "★", "Esperanza, inspiración y sanación.",
      "Confía: vas por buen camino."),
  TarotCard("XVIII", "La Luna", "☽", "Sueños, ilusiones y emociones profundas.",
      "No todo es lo que parece: observa con calma."),
  TarotCard("XIX", "El Sol", "☀", "Alegría, claridad y éxito.",
      "Comparte tu buena energía con alguien."),
  TarotCard("XX", "El Juicio", "♫", "Despertar, llamado y renacer.",
      "Responde a eso que llevas tiempo postergando."),
  TarotCard("XXI", "El Mundo", "◯", "Logro, plenitud y cierre feliz.",
      "Celebra lo que ya conseguiste."),
];

class DailyTip {
  static const List<String> tips = [
    "Toma agua antes del próximo capítulo.",
    "Una tarea de 5 minutos hecha vale más que una perfecta pendiente.",
    "Escribe una idea apenas aparezca; después se escapa.",
    "Levántate y estírate entre episodio y episodio.",
    "Hoy es buen día para ordenar un rincón de la casa.",
    "Agradece algo pequeño en voz alta.",
    "Guarda la partida y descansa la vista 20 segundos.",
    "Avanza un poquito en ese proyecto personal.",
    "Prepara la ropa de mañana antes de dormir.",
    "Pregúntale a tu persona favorita cómo le fue de verdad.",
    "Si algo te frustra, cámbialo por una pausa corta.",
    "Lee una página de algo que no sea una pantalla.",
    "Ventila la pieza diez minutos.",
    "Aprende un atajo nuevo del programa que más usas.",
    "Dibuja, escribe o crea algo sin juzgarlo.",
    "Revisa si hay algo que puedas delegar o pedir ayuda.",
    "Deja el celular en otra pieza durante la película.",
    "Escucha un disco completo, de principio a fin.",
    "Celebra el avance, no solo el resultado.",
    "Hoy toca dormir un poco antes.",
    "Prueba un juego indie que no conozcas.",
    "Anota tres cosas que salieron bien hoy.",
    "Haz una lista corta: tres prioridades, no diez.",
    "Riega las plantas (o adopta una).",
    "Comparte un descubrimiento con alguien.",
    "Respira profundo cuatro veces antes de responder un mensaje difícil.",
    "Termina algo pendiente antes de empezar algo nuevo.",
    "Camina diez minutos al sol.",
    "Prende una vela y dedica un rato a pensar sin apuro.",
    "Ordena tus archivos o tu escritorio digital.",
  ];

  static String ofDay(String profileId, DateTime date) =>
      tips[_dailySeed(profileId, date, 2) % tips.length];
}

class Astro {
  static const Map<String, String> _elements = {
    "aries": "fuego", "leo": "fuego", "sagitario": "fuego",
    "tauro": "tierra", "virgo": "tierra", "capricornio": "tierra",
    "geminis": "aire", "libra": "aire", "acuario": "aire",
    "cancer": "agua", "escorpio": "agua", "piscis": "agua",
  };

  static const Map<String, String> _signNames = {
    "aries": "Aries", "leo": "Leo", "sagitario": "Sagitario",
    "tauro": "Tauro", "virgo": "Virgo", "capricornio": "Capricornio",
    "geminis": "Géminis", "libra": "Libra", "acuario": "Acuario",
    "cancer": "Cáncer", "escorpio": "Escorpio", "piscis": "Piscis",
  };

  static const Map<String, List<String>> _byElement = {
    "fuego": [
      "Tu energía está encendida: canalízala en algo que te entusiasme.",
      "Día para tomar la iniciativa, pero sin quemarte.",
      "La pasión te guía; elige bien en qué la pones.",
    ],
    "tierra": [
      "Lo concreto te da paz: avanza paso a paso.",
      "Buen día para ordenar cuentas, espacios y rutinas.",
      "Tu constancia empieza a dar frutos.",
    ],
    "aire": [
      "Las ideas fluyen: anótalas y compártelas.",
      "Una conversación puede abrirte una puerta.",
      "Tu curiosidad está despierta; aprende algo nuevo.",
    ],
    "agua": [
      "Tus emociones hablan claro: escúchalas.",
      "Día sensible y creativo; dale espacio al arte.",
      "La intuición pesa más que la lógica hoy.",
    ],
  };

  static String? signName(String? sign) => sign == null ? null : _signNames[sign];

  static String energyOfDay(String profileId, String? sign, DateTime date) {
    final moon = MoonPhase.of(date);
    final element = sign == null ? null : _elements[sign];
    final String base;
    if (element == null) {
      const generic = [
        "Día para observar antes de actuar.",
        "La energía invita a cerrar pendientes.",
        "Buen momento para empezar algo pequeño.",
        "Ideal para conectar con quienes quieres.",
      ];
      base = generic[_dailySeed(profileId, date, 3) % generic.length];
    }
    else {
      final options = _byElement[element]!;
      base = options[_dailySeed(profileId, date, 3) % options.length];
    }
    return "$base ${_moonHint(moon.name)}";
  }

  static String _moonHint(String phase) {
    if (phase.contains("nueva")) return "La luna nueva favorece las intenciones.";
    if (phase.contains("llena")) return "La luna llena ilumina lo que estaba oculto.";
    if (phase.contains("creciente") || phase.contains("Creciente")) return "La luna creciente impulsa lo que siembras.";
    return "La luna menguante ayuda a soltar.";
  }
}
