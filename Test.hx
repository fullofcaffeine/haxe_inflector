import inflector.*;

using inflector.InflectorStringExtensions;

//List, Dictionary
//https://haxe.org/manual/std-ds.html

typedef Foo = {x:String, y:String}

class Test {
    public static function main() {
        trace("asd".pluralize());
//        trace(Inflections.instance());
    }
}
