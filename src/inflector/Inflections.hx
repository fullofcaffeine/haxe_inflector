package inflector;

import helpers.AcceptEither;

using thx.Strings;
using thx.Arrays;

typedef ReplacementMap = {
  @:optional public var RuleString:String;
  @:optional public var RuleRegex:EReg;
  public var Replacement:String;
}

enum FirstLetterCase {
  Upper;
  Lower;
}

@:expose
class Inflections {
  private static var _instance = new Map<String, Inflections>();
  public var plurals(default, null) = new Array<ReplacementMap>();
  public var singulars(default, null) = new Array<ReplacementMap>();
  public var uncountables(default , null) = new Array<String>();
  public var humans(default, null) = new Array<ReplacementMap>();
  public var acronyms(default, null) = new Map<String, String>();
  public var acronym_regex(default, null) = ~/(?=a)b/;

  private function new() {
  }

  public static function instance(locale:String = 'en'):Inflections {
    if (!_instance.exists(locale)) { 
      var inflect = new Inflections();
      populate_default_inflections(inflect);
     _instance.set(locale, inflect);
    }
    return _instance[locale];
  }

  public function acronym(word:String):Void {
    acronyms[word.toLowerCase()] = word;
    acronym_regex = new EReg(Lambda.array(acronyms).join('|'), 'i');
  }

  public function plural(rule:EReg, replacement:String):Void {
    uncountables.remove(replacement);
    plurals.insert(0, {RuleRegex: rule, Replacement: replacement});
  }

  public function singular(rule:AcceptEither<String, EReg>, replacement:String):Void {
    switch(rule.type) {
      case Left(str): 
        singulars.insert(0, {RuleString: str, Replacement: replacement});
        uncountables.remove(str);
      case Right(regex):
        singulars.insert(0, {RuleRegex: regex, Replacement: replacement});
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
      singular(new EReg('${s0.toLowerCase()}(?i)$srest$','i'), s0.toLowerCase() + srest);
      singular(new EReg('${p0.toUpperCase()}(?i)$prest$','i'), s0.toUpperCase() + srest);
      singular(new EReg('${p0.toLowerCase()}(?i)$prest$','i'), s0.toLowerCase() + srest);
    }
  }
  public function uncountable(words:Array<String>):Void {
    uncountables.concat(words.map(function(el) { return el.toLowerCase(); }));
  }

  public function human(rule:String, replacement:String):Void {
    humans.insert(0, {RuleRegex: new EReg(rule,'i'), Replacement: replacement});
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

  public static function inflections(locale:String = "en", ?block:Null<Inflections -> Void>):Inflections {
    if (block != null) block(Inflections.instance('en'));
    return Inflections.instance();
  }

  public static function populate_default_inflections(inflect:Inflections):Void 
  {
      inflect.plural(new EReg("$", 'i'), "s");
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

      inflect.uncountable(["equipment", "information", "rice", "money", "species", "series", "fish", "sheep", "jeans", "police"]);
  }

  public static function pluralize(word:String, locale:String = 'en'):String {
     return apply_inflections(word, inflections(locale).plurals);
  }

  public static function singularize(word:String, locale:String = 'en'):String {
     return apply_inflections(word, inflections(locale).singulars);
  }

  public static function camelize(term:String, uppercase_first_letter:Bool = true):String {
    if (uppercase_first_letter) {
      term = new EReg('^[a-z\\d]*', 'i').map(term, function(r) { 
        var match = r.matched(0);

        return inflections().acronyms.exists(match) 
          ? inflections().acronyms[match]
          : match.capitalize();
      });
    } else {
      term = new EReg("^(?:{inflections().acronym_regex}(?=\\b|[A-Z_])|\\w",'i').matched(0);
    }
    term = new EReg("(?:_|(\\/))([a-z\\d]*)",'i').map(term, function(r) { 
      var group_1 = r.matched(1);
      var group_2 = r.matched(2);
      var secondPart = inflections().acronyms.exists(group_2)
        ? inflections().acronyms[group_2]
        : group_2.capitalize();
      return '$group_1$secondPart';
    });
    term = term.replace("/", "::");
    return term;
  }

  public static function underscore(camel_cased_word:String):String
  {
    if (!~/[A-Z-]|::/.match(camel_cased_word)) return camel_cased_word;
    var word = camel_cased_word.replace("::", "/");
    word = new EReg("(?:(?<=([A-Za-z\\d]))|\\b)({inflections().acronym_regex})(?=\\b|[^a-z]",'i').map(word, function(r) {
      var group_1 = r.matched(1);
      var group_2 = r.matched(2);

      return (group_1 != null ? "_" : "") + group_2.toLowerCase();
    });
    word = new EReg("([A-Z\\d]+)([A-Z][a-z]",'i').replace(word, "$1_$2");
    word = new EReg("([a-z\\d])([A-Z])",'i').replace(word, "$1_$2");
    word = word.replace('-', '_');
    word = word.toLowerCase();
    return word;
  }

  private static function substitute(result:String, rules:Array<Inflections.ReplacementMap>)
  { 
    for (rule in rules) {
      if (rule.RuleRegex.match(result)) {
        result = rule.RuleRegex.replace(result, rule.Replacement);
        break;
      }
    }
    return result;
  }

  public static function humanize(lower_case_and_underscored_word:String, capitalize:Bool = true):String
  {
    var result = lower_case_and_underscored_word;

    result = substitute(result, inflections().humans);
    result = new EReg("\\A_+",'i').replace(result, "");
    // CS code had an `1` as the last param for replace, why?
    result = new EReg("_id\\z",'i').replace(result, "");
    result = result.replace('_', ' ');
    result = new EReg("([a-z\\d]*)",'i').map(result, function(r) {
      var match = r.matched(0);
      return inflections().acronyms.exists(match) 
        ? inflections().acronyms[match]
        : match.toLowerCase();
    });

    if(capitalize) {
      result = new EReg("\\A\\w",'i').map(result, function(r) {
        var match = r.matched(0);
        return match.toUpperCase();
      });
    }

    return result;
  }

  public static function titleize(word:String):String
  {
     return  new EReg("\\b(?<!['’`])[a-z]", 'i').map(humanize(underscore(word)), function(r) {
        return r.matched(0).capitalize();
      });
  }

  public static function tableize(class_name: String)
  {
    return pluralize(underscore(class_name));
  }

  public static function classify(table_name: String)
  {
      // strip out any leading schema name
      return camelize(singularize(new EReg(".*\\.", 'i').replace(table_name, "")));
  }

  public static function dasherize(underscored_word: String)
  {
      return underscored_word.replace('_', '-');
  }

  public static function demodulize(path: String)
  {
      var ind = path.lastIndexOf("::");
      return ind >= 0 ? path.substring(ind + 2) : path;
  }

  public static function deconstantize(path: String)
  {
      var ind = path.lastIndexOf("::");
      return path.substring(0, ind >= 0 ? ind : 0);
  }

  public static function foreign_key(class_name:String, separate_class_name_and_id_with_underscore:Bool = true)
  {
      return underscore(demodulize(class_name)) + (separate_class_name_and_id_with_underscore ? "_id" : "id");
  }

  public static function constantize(camel_cased_word: String)
  {
    // Not implemented
  }

  public static function safe_constantize(camel_cased_word: String)
  {
    // Not implemented
  }

  public static function ordinal(numberStr: String)
  {
      var number = Std.parseInt(numberStr);
      var abs_number = Math.abs(number);

      if (abs_number % 100 >= 11 && abs_number % 100 <= 13)
          return "th";

      switch (abs_number % 10)
      {
          case 1:
              return "st";
          case 2:
              return "nd";
          case 3:
              return "rd";
          default:
              return "th";
      }
  }

  public static function ordinalize(data: AcceptEither<String, Int>)
  {
      var data = return switch(data.type) {
        case Left(str): str;
        case Right(int): Std.string(int);
      }
      return '$data${ordinal(data)}';
  }

  public static function eregReplace(str: String) {
    return str.replace('[-\\/\\^$*+?.()|[\\]{}]/g', '\\$&');
  }

  public static function parameterize(str: String, sep: String = "\\-")
  {
      // replace accented chars with their ascii equivalents
      var parameterized_string = transliterate(str);
      // Turn unwanted chars into the separator
      parameterized_string = new EReg("[^a-z0-9\\-_]+", 'i').replace(parameterized_string, sep);

      if (sep != null)
      {
          var re_sep = new EReg(eregReplace(sep), 'i');
          // No more than one of the separator in a row.
          parameterized_string = new EReg(re_sep + "{2,}", 'i').replace(parameterized_string, sep);
          // Remove leading/trailing separator.
          parameterized_string = new EReg("^{re_sep}|{re_sep}$", 'i').replace(parameterized_string, "");
      }
      return parameterized_string.toLowerCase();
  }

  private static function apply_inflections(word: String, rules:Array<ReplacementMap>)
  {
      var result = word;

      if ((word == null || word == '') || inflections().uncountables.contains(result.toLowerCase()))
          return result;

      return substitute(result, rules);
  }

  public static function transliterate(str: String, replacement:String = "?")
  {
    //NOt implemented
    return '';
  }
}


