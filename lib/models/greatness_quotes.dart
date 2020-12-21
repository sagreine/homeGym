import 'dart:math';

class Quotes {
  static final Quotes _singleton = Quotes._internal();

  factory Quotes() {
    return _singleton;
  }

  Quotes._internal();
  /*{
    _greatness = List<String>();
  }*/

  String getQuote({bool greatnessQuote, int seed}) {
    if (greatnessQuote) {
      return _greatness[seed ?? Random().nextInt(_greatness.length)];
    } else {
      return _failure[seed ?? Random().nextInt(_failure.length)];
    }
  }

  static List<String> _greatness = [
    "My god, I've done it.",
    "I am God's gift to lifting.",
    "It's my world, you're just living in it.",
    "It's hard to be humble when you're as great as I am.",
    "Some people like to call me cocky or arrogant, but I just think 'how dare you assume I should think less of myself'.",
    "I'm allergic to coming in second but I never sneeze.",
    "Do it. For America.",
    "It's not cockiness, I'm just not oblivious.",
    "I can't help but laugh at how perfect I am.",
    "I am better at this than you are at anything you've ever done.",
    "If you even dream of beating me you better wake up and apologize.",
    "I do greater things by accident than you've ever done on purpose.",
    "Ladies and gentleman, you're welcome.",
    "Yes, really. It's fine if you need a minute.",
    "I once thought about failing. Once.",
    "The sun is alone too but still shines.",
    "Is my greatness still news?",
    "You can take the talent out of raw, but ain't nobody taking the raw out of my talent.",
    "If being this great is wrong I don't want to be right.",
    "I'd like to take a moment to thank everyone who got me here today, starting with myself.",
    "Either I will find a way or I will make one.",
    "No price is too high to pay for the privilege of owning yourself.",
    "When a great truth once gets abroad in the world, no power on earth can imprison it, or prescribe its limits, or suppress it.",
    "Let him who loves his self with his heart, and not merely with his lips, follow me.",
    "I intend to live forever, or die trying.",
    "This is where normal people bow down to me.",
    "Haters are to me as practice is to Iverson.",
    "It's going to be awkward for both of us when you have to apologize to me.",
    "King Kong just needed me to get at Denzel.",
    "'I never thought you would get there' Yeah well that makes one of us.",
    "Get you some."
  ];
  static List<String> _failure = [
    "First time lifting, eh?",
    "I mean you could always take up crocheting.",
    "You let the whole team down.",
    "No worries, it's just your teammates and everyone counting on you.",
    "Failure is just a part of life, but you could try not making it your whole life",
    "I'd give up if I were you. But that's why I'm not you and you're not me.",
    "It's fine. I've got things I pretend to want to accomplish too.",
    "A good plan violently executed today is better than a perfect plan executed next week.",
    "Glory is fleeting, but obscurity is forever.",
    "If he fails, at least fails while daring greatly, so that his place shall never be with those cold and timid souls who neither know victory nor defeat.",
    "I would rather die on my feet than live on my knees.",
    "Cowards die many times before their deaths; The valiant never taste of death but once.",
    "Come on, you sons of b****s, do you want to live forever?",
    "If you want a taste of freedom, keep going.",
    "If you give up now, years from now we'll remember only that you failed",
    "Nothing matters less than the lamentations of the man esteemed by none",
    "He who wants to be an eagle can fly. He who wants to be a worm can drag himself on the floor, but he should not scream when he is stepped on.",
    "May the eyes of cowards never sleep.",
    "Feel free to lie to anyone else in your life but don't lie to yourself.",
    "Some people are just born to be background characters in a much more interesting person's story.",
    "The only thing all of your failures have in common is you.",
    "The person you want to be wouldn't have failed today.",
    "My grandfather didn't handle business in the 40s so you could give that kind of effort.",
    "You are exactly what is wrong with society.",
    "So, wait, this is you trying?",
    "You, sir, make my generation look bad",
    "So that's what Tom Cruise would've looked like trying to handle the truth",
    "Hey, don't worry about it. Someone has to come in second.",
    "It's fine if you don't care.",
    "And that is why no one will remember your name.",
    "Maybe next lifetime I guess?",
    "I guess everything people say about you behind your back is true.",
    "I see why you work out alone at home.",
  ];
}
