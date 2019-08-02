package;

class Index
{
    public static function main()
    {
        #if php
        var app = new src.Php.App();
        app.run();
        #end
    }
}
