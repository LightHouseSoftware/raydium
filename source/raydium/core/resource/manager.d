module raydium.core.resource.manager;

import std.file;
import std.path;
import std.array;
import std.stdio;
import std.string;
import std.algorithm;
import std.zlib;
import std.conv;
import std.typecons;
import std.concurrency;
import std.parallelism;

import botan.libstate.global_state;
import botan.rng.rng;
import botan.rng.auto_rng;
import botan.constructs.cryptobox;

import raydium.core;

alias ResourceManager = ResourceManagerSingleton.instance;
class ResourceManagerSingleton {
    private {
        __gshared ResourceManagerSingleton _instance;
        Resource[][string] _indexes;
    }

    protected this() {
        auto state = globalState();
    }

    public static ResourceManagerSingleton instance() {
        if (!_instance) {
            synchronized (ResourceManagerSingleton.classinfo) {
                if (!_instance)
                    _instance = new ResourceManagerSingleton;
            }
        }

        return _instance;
    }

    debug
    {
        import std.stdio;
        
        void printIndexes()
        {
            foreach (key, value; _indexes)
            {
                writeln(key, ": ", value);
            }
        }
    }

    void loadResourceFile(string path, string passPhrase = "")
    {
        path = buildNormalizedPath(path);

        if(path.extension != ".ares")
        {
            throw new FileException("File " ~ path ~ " has an invalid extension");
        }
        else if(!path.exists)
        {
            throw new FileException("File " ~ path ~ " not found");
        }

        auto data = readToUbyteArray(path);
        
        // получить заголовок
        auto header = data[0 .. 15];

        if(header[0 .. 4] != "ARES".representation)
        {
            throw new Exception("File " ~ path ~ " has an invalid format");
        }

        // файл шифрован или нет, если бит выставлен, то да
        bool encrypted = ((header[6] & 0b10000000) != 0);

        size_t indexLen = bytesToUlong(header[7 .. 15]); // длина индекса

        data = data[15 .. $];
        data = prepareResource(data, encrypted, passPhrase);

        _indexes[path] = parse(data, indexLen);

        infof("Resource file `%s` has been loaded.", path);
    }

    Resource resource(string id)
    {
        if (ResourceCache.isResource(id))
        {
            return ResourceCache.resource(id).get;
        }

        foreach (key, value; _indexes)
        {
            if(value.canFind!(a => a.id == id))
            {
                auto res = value.find!(a => a.id == id)[0];
                
                ResourceCache.resource(id, res);

                return ResourceCache.resource(id).get;
            }
        }

        throw new Exception("Resource with id `" ~ id ~ "` not found");
    }

    private ubyte[] prepareResource(ubyte[] data, bool encrypted = false, string passPhrase = "")
    {
        if(data.empty) return data;

        data = cast(ubyte[]) uncompress(data);
        
        if (encrypted)
        {
            data = cast(ubyte[]) CryptoBox.decrypt(data.ptr, data.length, passPhrase).representation;
        }

        return data;
    }

    private Resource[] parse(ubyte[] data, size_t indexLen)
    {
        Resource[] resources;

        size_t i = 0;
        while (i < indexLen)
        {
            Resource res;

            // Получаем длину id
            ubyte idLength = data[i++];

            // Получаем id
            if (i + idLength <= indexLen)
            {
                res.id = cast(string) data[i .. i + idLength];
                i += idLength;
            }
            else
            {
                throw new Exception("Invalid data: id length is inconsistent");
            }

            // Получаем длину ext
            ubyte extLength = data[i++];

            // Получаем ext
            if (i + extLength <= indexLen)
            {
                res.ext = cast(string) data[i .. i + extLength];
                i += extLength;
            }
            else
            {
                throw new Exception("Invalid data: ext length is inconsistent");
            }

            // Получаем смещение
            size_t start = 0;
            if (i + 8 <= indexLen)
            {
                start = bytesToUlong(data[i .. i + 8]) + indexLen;
                i += 8;
            }
            else
            {
                throw new Exception("Invalid data: indexLen is inconsistent");
            }

            size_t end = 0;
            if (i + 8 <= indexLen)
            {
                end = bytesToUlong(data[i .. i + 8]) + start;
                i += 8;
            }
            else
            {
                throw new Exception("Invalid data: size is inconsistent");
            }

            res.data = data[start .. end];

            resources ~= res;
        }

        return resources.sort!((a,b) => a.id < b.id).array;
    }

    private ubyte[] readBytesInRange(string filePath, size_t start, size_t end)
    {
        if (end <= start)
        {
            throw new Exception("Invalid range: end must be greater than start.");
        }

        size_t range = end - start;
        ubyte[] buffer;
        buffer.length = range;

        auto file = File(filePath, "rb");
        file.seek(start, SEEK_SET);
        file.rawRead(buffer);
        file.close();

        return buffer;
    }

    ubyte[] readToUbyteArray(string path)
    {
        if (!path.exists)
        {
            throw new Exception("File not found: " ~ path);
        }

        ubyte[] data;

        ubyte[2048] buffer;
        auto file = File(path, "rb");
        while (!file.eof())
        {
            auto bytesRead = file.rawRead(buffer);
            data ~= bytesRead;
        }
        file.close();

        return data;
    }

    private ulong bytesToUlong(ubyte[] bytes)
    {
        version (BigEndian)
        {
            ulong result = 0;
            foreach (b; bytes)
            {
                result = (result << 8) | b;
            }
            return result;
        }
        version (LittleEndian)
        {
            ulong result = 0;
            foreach (index, b; bytes)
            {
                result |= (cast(ulong) b) << (8 * index);
            }
            return result;
        }
    }
}

struct Resource
{
    string id;
    string ext;
    ubyte[] data;
}