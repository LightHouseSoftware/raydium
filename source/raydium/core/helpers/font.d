module raydium.core.helpers.font;

import raydium.core;
import std.string;

class FontHelper
{
    public static Font loadFontFromMemory(string fontName, int fontSize = 12, int glyphPadding = 4)
    { 
        auto fontData = ResourceCache.font(fontName, fontSize);
        if(!fontData.isNull)
        {
            return fontData.get.font;
        }
        
        auto fontRes = ResourceManager.resource(fontName);

        FT_Library library;
        FT_Face face;

        // Инициализация FreeType
        if (FT_Init_FreeType(&library))
        {
            throw new Exception("Freetype library initialization error");
        }

        // Загрузка шрифта из памяти
        if (FT_New_Memory_Face(library, fontRes.data.ptr, cast(int) fontRes.data.length, 0, &face))
        {
            // Обработка ошибки создания шрифта
            throw new Exception("Freetype font load error for font " ~ fontName);
        }

        FT_ULong charcode;
        FT_UInt gindex;

        int[] fontCodepoints;

        charcode = FT_Get_First_Char(face, &gindex);
        while (gindex != 0)
        {
            fontCodepoints ~= charcode;
            charcode = FT_Get_Next_Char(face, charcode, &gindex);
        }

        int codepointCount = face.num_glyphs;

        FT_Done_Face(face);
        FT_Done_FreeType(library);

        if (fontRes.ext.toLower == ".ttf" || fontRes.ext.toLower == ".otf")
        {
            Font font;
            font.baseSize = fontSize;
            font.glyphCount = (codepointCount > 0) ? codepointCount : 95;
            font.glyphPadding = 0;
            font.glyphs = LoadFontData(fontRes.data.ptr, cast(int) fontRes.data.length, font.baseSize, fontCodepoints.ptr, font.glyphCount, FontType.FONT_DEFAULT);

            if (font.glyphs != null)
            {
                font.glyphPadding = glyphPadding;
                
                info(font.glyphCount);
                info(fontTextureSize(font.baseSize));

                Image atlas = GenImageFontAtlas(font.glyphs, &font.recs, font.glyphCount, fontTextureSize(font.baseSize), font.glyphPadding, 0);

                info(atlas);

                font.texture = LoadTextureFromImage(atlas);

                info("TEST4");

                for (int i = 0; i < font.glyphCount; i++)
                {
                    UnloadImage(font.glyphs[i].image);
                    font.glyphs[i].image = ImageFromImage(atlas, font.recs[i]);
                }

                info("TEST5");

                UnloadImage(atlas);

                ResourceCache.font(FontResource(font, fontSize, fontName));

                info("TEST6");

                infof("FONT: Data loaded successfully (%d pixel size | %d glyphs)", fontTextureSize(font.baseSize), font.glyphCount);

                return font;
            }
        }

        return GetFontDefault();
    }

    private static int fontTextureSize(uint fontSize)
    {
        auto sz = fontSize * 2;
        return cast(int)((sz % 2 == 0) ? sz : sz + 1);
    }
}