module raydium.core.resource.cache;

import raydium.core;
import std.typecons;
import std.array;
import std.algorithm;

alias ResourceCache = ResourceCacheManager.instance;
// alias CachedResource = RefCounted!(Resource);
// alias CachedTexture = RefCounted!(Texture2D);

class ResourceCacheManager {
    private {
        __gshared ResourceCacheManager _instance;
       
       Resource[string] _resources;
       Texture2D[string] _textures;
       Shader[string] _shaders;
       FontResource[] _fonts;
    }

    protected this() {
    }

    public static ResourceCacheManager instance() {
        if (!_instance) {
            synchronized (ResourceCacheManager.classinfo) {
                if (!_instance)
                    _instance = new ResourceCacheManager;
            }
        }

        return _instance;
    }

    bool isResource(string id)
    {
        return (id in _resources) !is null;
    }

    bool isTexture(string id)
    {
        return (id in _textures) !is null;
    }

    bool isShader(string id)
    {
        return (id in _shaders) !is null;
    }

    Nullable!Texture2D texture(string id)
    {
        if(isTexture(id))
        {
            return Nullable!Texture2D(_textures[id]);
        }

        return Nullable!Texture2D.init;
    }

    void texture(string id, Texture2D texture)
    {
        _textures[id] = texture;
    }

    Nullable!Resource resource(string id)
    {
        if (isResource(id))
        {
            return Nullable!Resource(_resources[id]);
        }

        return Nullable!Resource.init;
    }

    void resource(string id, Resource res)
    {
        _resources[id] = res;
    }

    Nullable!Shader shader(string id)
    {
        if (isShader(id))
        {
            return Nullable!Shader(_shaders[id]);
        }

        return Nullable!Shader.init;
    }

    void shader(string id, Shader shader)
    {
        _shaders[id] = shader;
    }

    bool isFont(string id, uint fontSize)
    {
        return _fonts.canFind!(f => f.id == id && f.size == fontSize);
    }

    // Метод для получения шрифта
    Nullable!FontResource font(string id, uint fontSize)
    {
        foreach (fontd; _fonts)
        {
            if(fontd.id == id && fontd.size == fontSize)
            {
                return Nullable!FontResource(fontd);
            }
        }
        return Nullable!FontResource.init;
    }

    // Метод для установки шрифта
    void font(FontResource newFont)
    {
        if(_fonts.empty)
        {
           _fonts ~= newFont;
        }
        else 
        {
            foreach (key, fontd; _fonts)
            {
                if (fontd.id == newFont.id && fontd.size == newFont.size)
                {
                    _fonts[key] = newFont;
                }
                else
                {
                    _fonts ~= newFont;
                }
            }
        }
    }
}

struct FontResource
{
    Font font;
    alias font this;
    uint size;
    string id;
}