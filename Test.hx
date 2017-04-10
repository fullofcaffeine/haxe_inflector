import inflector.*;
import haxe.unit.*;

//TODO: Test other methods
//TODO: Create static extensions

class Test extends TestCase {
    public static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new Test());
        r.run();
   }

    function test() {
       assertEquals(Inflections.pluralize('person'), 'people');
       assertEquals(Inflections.pluralize('car'), 'cars');
       assertEquals(Inflections.singularize('cars'), 'car');
       assertEquals(Inflections.singularize('people'), 'person');
    }
}
