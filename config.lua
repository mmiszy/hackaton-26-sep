application =
{
    content =
    {
        width = 768,
        height = 1024,

        scale = "zoomStretch",

        imageSuffix =
        {
           -- ["@1-5"] = 1.5,		-- for Droid, Nexus One, etc.
            ["@2x"] = 1,    	-- for iPhone, iPod touch, iPad1, and iPad2
           -- ["@3x"] = 3,    	-- for various mid-size Android tablets
            ["@retina"] = 2,	-- for iPad 3
        }
    }
}