package inflector;

import helpers.AcceptEither;
import thx.*;

typedef ReplacementMap = {
  @:optional public var RuleString:String;
  @:optional public var RuleRegex:EReg;
  public var Replacement:String;
}

enum FirstLetterCase {
  Upper;
  Lower
}

class Inflections {
  private static var _instance = new Map<String, Inflections>();
  public var plurals(default, null) = new Array<ReplacementMap>();
  public var singulars(default, null) = new Array<ReplacementMap>();
  public var uncountables(default , null) = new Array<String>();
  public var humans(default, null) = new Array<ReplacementMap>();
  public var acronyms(default, null) = new Map<String, String>();
  public var acronym_regex(default, null) = ~/(?=a)b/;

  private function new() {
    // populate_default_inflections();
  }

  public static function instance(locale:String = 'en'):Inflections {
    if (!_instance.exists(locale)) _instance[locale] = new Inflections();
    return _instance[locale]
  }

  public function acronym(word:String):Void {
    acronyms[word.toLowerCase()] = word;
    acronym_regex = new EReg(Lambda.array(acronyms).join('|'), 'i')
  }


  public function plural(rule:EReg, replacement:String):Void {
    uncountables.remove(replacement);
    plurals.Insert(0, {RuleRegex = rule, Replacement = replacement});
  }

  public function singular(rule:AcceptEither<String, EReg>, replacement:String):Void {
    switch(rule.type) {
      case Left(str): 
        singulars.insert(0, {RuleString: str, Replacement: replacement})
          uncountables.remove(str);
      case Right(regex):
        singulars.insert(0, {RuleRegex: regex, Replacement: replacement})
    }
    uncountables.remove(replacement);
  }

  public function irregular(singular_str:String, plural_str:String):Void {
    uncountables.remove(singular_str);
    uncountables.remove(plural_str);

    var s0 = singular_str.substr(0, 1);
    var srest = singular_str.substr(1);

    var p0 = plural_str.substr(0, 1);
    var prest = plural_str.substr(1);

    if (s0.toUpperCase() == p0.toUpperCase()) {
      plural(new EReg('($s0)$srest$','i'), "$1" + prest);
      plural(new EReg('($p0)$prest$','i'), "$1" + prest);

      singular(new EReg('($s0)$srest$','i'), "$1" + srest);
      singular(new EReg('($p0)$prest$','i'), "$1" + srest);
    } else {
      plural(new EReg('${s0.toUpperCase()}(?i)$srest$','i'), p0.toUpperCase() + prest);
      plural(new EReg('${s0.toLowerCase()}(?i)$srest$','i'), p0.toLowerCase() + prest);
      plural(new EReg('${p0.toUpperCase()}(?i)$prest$','i'), p0.toUpperCase() + prest);
      plural(new EReg('${p0.toLowerCase()}(?i)$prest$','i'), p0.toLowerCase() + prest);

      singular(new EReg('${s0.toUpperCase()}(?i)$srest$','i'), s0.toUpperCase() + srest);
      singular(new EReg({'${s0.toLowerCase()}(?i)$srest$','i'), s0.toLowerCase() + srest);
        singular(new EReg('${p0.toUpperCase()}(?i)$prest$','i'), s0.toUpperCase() + srest);
        singular(new EReg('${p0.toLowerCase()}(?i)$prest$','i'), s0.toLowerCase() + srest);
      }
    }
  }
  public function uncountable(words:Array<String>):Void {
    uncountables.concat(words.map(function(el) { return el.toLowerCase() }))
  }

  public function human(rule:String, replacement:String):Void {
    humans.insert(0, {RuleRegex = rule, Replacement = replacement})
  }

  public function clear(scope:String) {
    if (scope == "All")
    {
      plurals = new Array<ReplacementMap>();
      singulars  = new Array<ReplacementMap>();
      uncountables = new Array<String>();
      humans = new Array<ReplacementMap>();
    }
    else if (scope == "plurals")  plurals = new Array<ReplacementMap>();
    else if (scope == "singulars") singulars  = new Array<ReplacementMap>();
    else if (scope == "uncountables") uncountables = new Array<String>();
    else if (scope == "humans") humans = new Array<ReplacementMap>();
  }

  public static function inflections(locale:String = "en", block:Null<Inflections -> Void>):Inflections {
    if (block != null) block(Inflections.instance('en'))
      return Inflections.instance();
  }

  public static populate_default_inflections():Void 
  {
    inflections("en", function(inflect) {
          inflect.plural(new EReg("$"), "s");
          inflect.plural(new EReg("s$", 'i'), "s");
          inflect.plural(new EReg("^(ax|test)is$", 'i'), "$1es");
          inflect.plural(new EReg("(octop|vir)us$", 'i'), "$1i");
          inflect.plural(new EReg("(octop|vir)i$", 'i'), "$1i");
          inflect.plural(new EReg("(alias|status)$", 'i'), "$1es");
          inflect.plural(new EReg("(bu)s$", 'i'), "$1ses");
          inflect.plural(new EReg("(buffal|tomat)o$", 'i'), "$1oes");
          inflect.plural(new EReg("([ti])um$", 'i'), "$1a");
          inflect.plural(new EReg("([ti])a$", 'i'), "$1a");
          inflect.plural(new EReg("sis$", 'i'), "ses");
          inflect.plural(new EReg("(?:([^f])fe|([lr])f)$", 'i'), "$1$2ves");
          inflect.plural(new EReg("(hive)$", 'i'), "$1s");
          inflect.plural(new EReg("([^aeiouy]|qu)y$", 'i'), "$1ies");
          inflect.plural(new EReg("(x|ch|ss|sh)$", 'i'), "$1es");
          inflect.plural(new EReg("(matr|vert|ind)(?:ix|ex)$", 'i'), "$1ices");
          inflect.plural(new EReg("^(m|l)ouse$", 'i'), "$1ice");
          inflect.plural(new EReg("^(m|l)ice$", 'i'), "$1ice");
          inflect.plural(new EReg("^(ox)$", 'i'), "$1en");
          inflect.plural(new EReg("^(oxen)$", 'i'), "$1");
          inflect.plural(new EReg("(quiz)$", 'i'), "$1zes");

          inflect.singular(new EReg("s$", 'i'), "");
          inflect.singular(new EReg("(ss)$", 'i'), "$1");
          inflect.singular(new EReg("(n)ews$", 'i'), "$1ews");
          inflect.singular(new EReg("([ti])a$", 'i'), "$1um");
          inflect.singular(new EReg("((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$", 'i'), "$1sis");
          inflect.singular(new EReg("(^analy)(sis|ses)$", 'i'), "$1sis");
          inflect.singular(new EReg("([^f])ves$", 'i'), "$1fe");
          inflect.singular(new EReg("(hive)s$", 'i'), "$1");
          inflect.singular(new EReg("(tive)s$", 'i'), "$1");
          inflect.singular(new EReg("([lr])ves$", 'i'), "$1f");
          inflect.singular(new EReg("([^aeiouy]|qu)ies$", 'i'), "$1y");
          inflect.singular(new EReg("(s)eries$", 'i'), "$1eries");
          inflect.singular(new EReg("(m)ovies$", 'i'), "$1ovie");
          inflect.singular(new EReg("(x|ch|ss|sh)es$", 'i'), "$1");
          inflect.singular(new EReg("^(m|l)ice$", 'i'), "$1ouse");
          inflect.singular(new EReg("(bus)(es)?$", 'i'), "$1");
          inflect.singular(new EReg("(o)es$", 'i'), "$1");
          inflect.singular(new EReg("(shoe)s$", 'i'), "$1");
          inflect.singular(new EReg("(cris|test)(is|es)$", 'i'), "$1is");
          inflect.singular(new EReg("^(a)x[ie]s$", 'i'), "$1xis");
          inflect.singular(new EReg("(octop|vir)(us|i)$", 'i'), "$1us");
          inflect.singular(new EReg("(alias|status)(es)?$", 'i'), "$1");
          inflect.singular(new EReg("^(ox)en", 'i'), "$1");
          inflect.singular(new EReg("(vert|ind)ices$", 'i'), "$1ex");
          inflect.singular(new EReg("(matr)ices$", 'i'), "$1ix");
          inflect.singular(new EReg("(quiz)zes$", 'i'), "$1");
          inflect.singular(new EReg("(database)s$", 'i'), "$1");

          inflect.irregular("person", "people");
          inflect.irregular("man", "men");
          inflect.irregular("child", "children");
          inflect.irregular("sex", "sexes");
          inflect.irregular("move", "moves");
          inflect.irregular("zombie", "zombies");

          inflect.uncountable("equipment", "information", "rice", "money", "species", "series", "fish", "sheep", "jeans", "police");
        });
    }
  }

