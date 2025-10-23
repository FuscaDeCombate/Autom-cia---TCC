using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Automácia
{
    public static class Funcionario
    {
        private static int id;
        private static int idTipo;
        private static int cnpj;
        private static string nome;

        public static int Id { get => id; set => id = value; }
        public static int IdTipo { get => idTipo; set => idTipo = value; }
        public static int Cnpj { get => cnpj; set => cnpj = value; }
        public static string Nome { get => nome; set => nome = value; }
    }
}
