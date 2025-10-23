using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Automácia
{
    public class Receita
    {
        public int Id { get; set; }
        public DateTime DataReceita { get; set; }
        public DateTime DataValidade { get; set; }
        public string IdFuncionario { get; set; }
        public string NomeFuncionario { get; set; }
        public string IdPaciente { get; set; }
        public string Medicamento { get; set; }
        public string Detalhes { get; set; }
        public int LimitesBaixas { get; set; }
        public bool Valido { get; private set; }
        public int Baixas { get; set; }

        public Receita(DataTable dtReceita, int idReceita)
        {
            Id = int.Parse(dtReceita.Rows[idReceita]["ID_Receita"].ToString());
            DataReceita = DateTime.Parse(dtReceita.Rows[idReceita]["Data_Receita"].ToString());
            DataValidade = DateTime.Parse(dtReceita.Rows[idReceita]["Data_Validade"].ToString());
            IdFuncionario = dtReceita.Rows[idReceita]["Funcionar_Rec"].ToString();
            NomeFuncionario = dtReceita.Rows[idReceita]["Funcionar_Nome"].ToString();
            IdPaciente = dtReceita.Rows[idReceita]["Paciente_F"].ToString();
            Medicamento = dtReceita.Rows[idReceita]["Medicamento"].ToString();
            Detalhes = dtReceita.Rows[idReceita]["Detalhes"].ToString();
            LimitesBaixas = int.Parse(dtReceita.Rows[idReceita]["Limite_Baixas"].ToString());
            Valido = bool.Parse(dtReceita.Rows[idReceita]["Valido"].ToString());
            Baixas = int.Parse(dtReceita.Rows[idReceita]["Baixas"].ToString());
        }
    }
}
