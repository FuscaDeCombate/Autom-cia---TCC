using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public static class FileUtils
{
    //---------------------------------------------Métodos sobre a Manipulação de Arquivos Externos--------------------------------------------
    //----------Conversão Síncrona----------
    // Converter um Arquivo para dado em Binário
    public static byte[] ArquivoParaBinario(string caminhoArquivo)
    {
        if (!File.Exists(caminhoArquivo))
        {
            throw new FileNotFoundException("Arquivo não encontrado.", caminhoArquivo);
        }

        return File.ReadAllBytes(caminhoArquivo);
    }

    // Converter um dado em Binário para um Arquivo
    public static void BinarioParaArquivo(byte[] dados, string caminhoSaida)
    {
        if (dados == null || dados.Length == 0)
        {
            throw new ArgumentException("O array de bytes está vazio ou nulo.");
        }

        string diretorio = Path.GetDirectoryName(caminhoSaida);
        if (!Directory.Exists(diretorio))
        {
            Directory.CreateDirectory(diretorio);
        }

        File.WriteAllBytes(caminhoSaida, dados);
    }


    //----------Conversão Assíncrona----------
    // Converter um Arquivo para dado em Binário
    public static async Task<byte[]> ArquivoParaBinarioAssinc(string caminhoArquivo)
    {
        if (!File.Exists(caminhoArquivo))
            throw new FileNotFoundException("Arquivo não encontrado.", caminhoArquivo);

        using (var fs = new FileStream(caminhoArquivo, FileMode.Open, FileAccess.Read, FileShare.Read, 4096, useAsync: true))
        using (var ms = new MemoryStream())
        {
            await fs.CopyToAsync(ms).ConfigureAwait(false);
            return ms.ToArray();
        }
    }

    // Converter um dado em Binário para um Arquivo
    public static async Task BinarioParaArquivoAssinc(byte[] dados, string caminhoSaida)
    {
        if (dados == null || dados.Length == 0)
            throw new ArgumentException("O array de bytes está vazio ou nulo.", nameof(dados));

        string diretorio = Path.GetDirectoryName(caminhoSaida);
        if (!string.IsNullOrEmpty(diretorio) && !Directory.Exists(diretorio))
            Directory.CreateDirectory(diretorio);

        using (var fs = new FileStream(caminhoSaida, FileMode.Create, FileAccess.Write, FileShare.None, 4096, useAsync: true))
        {
            await fs.WriteAsync(dados, 0, dados.Length).ConfigureAwait(false);
            await fs.FlushAsync().ConfigureAwait(false);
        }
    }
}