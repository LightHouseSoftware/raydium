module raydium.core.resource.manager;

import std.file;
import std.path;
import std.array;
import std.stdio;
import std.string;
import std.algorithm;
import std.zlib;
import std.conv;

import botan.libstate.global_state;
import botan.rng.rng;
import botan.rng.auto_rng;
import botan.constructs.cryptobox;

alias ResourceManager = ResourceManagerSingleton.instance;
class ResourceManagerSingleton {
    private {
        __gshared ResourceManagerSingleton _instance;
        ResourceIndex[][string] _indexes;
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

    void loadResourceIndex(string path, string resId, string passPhrase = "")
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
        
        // получить заголовок
        auto header = readBytesInRange(path, 0, 15);

        if(header[0 .. 4] != "ARES".representation)
        {
            throw new Exception("File " ~ path ~ " has an invalid format");
        }

        // файл шифрован или нет, если бит выставлен, то да
        bool encrypted = ((header[6] & 0b10000000) != 0);

        size_t indexLen = bytesToUlong(header[7 .. 15]); // длина индекса

        auto indexRaw = readBytesInRange(path, header.length, header.length+indexLen);

        indexRaw = prepareResource(indexRaw, encrypted, passPhrase);

        _indexes[resId] ~= parseResourceIndex(indexRaw, header.length + indexLen);
    }

    //TODO: найти и прочитать файл
    // распаковать
    // расшифровать, если надо
    // прочитать и расшифровать индекс
    // по индексу найти сдвиг и длину файла
    // считать и вернуть нужный диапазон байт из файла

    // проблема в том, что файл сжат или даже зашифрован, поэтому невозможно считываь кусками

    private ubyte[] prepareResource(ubyte[] data, bool encrypted = false, string passPhrase = "")
    {
        data = cast(ubyte[]) uncompress(data);
        
        if (encrypted)
        {
            data = cast(ubyte[]) CryptoBox.decrypt(data.ptr, data.length, passPhrase).representation;
        }

        return data;
    }

    private ResourceIndex[] parseResourceIndex(ubyte[] data, size_t offset)
    {
        ResourceIndex[] resourceIndex;

        size_t i = 0;
        while (i < data.length)
        {
            ResourceIndex res;

            // Получаем длину id
            ubyte idLength = data[i++];

            // Получаем id
            if (i + idLength <= data.length)
            {
                res.id = cast(string) data[i .. i + idLength];
                i += idLength;
            }
            else
            {
                throw new Exception("Invalid data: id length is inconsistent");
            }

            // Получаем смещение
            if (i + 8 <= data.length)
            {
                res.start = bytesToUlong(data[i .. i + 8]) + offset;
                i += 8;
            }
            else
            {
                throw new Exception("Invalid data: offset is inconsistent");
            }

            if (i + 8 <= data.length)
            {
                res.end = bytesToUlong(data[i .. i + 8]) + offset;
                i += 8;
            }
            else
            {
                throw new Exception("Invalid data: size is inconsistent");
            }

            resourceIndex ~= res;
        }

        return resourceIndex.sort!((a,b) => a.id < b.id).array;
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

struct ResourceIndex
{
    string id;
    size_t start;
    size_t end;
}