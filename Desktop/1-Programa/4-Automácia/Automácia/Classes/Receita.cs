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
        private int id;
        private DateTime dataReceita;
        private DateTime dataValidade;
        private string idFuncionario;
        private string nomeFuncionario;
        private string idPaciente;
        private string medicamento;
        private string detalhes;
        private int limitesBaixas;
        private bool valido;
        private int baixas;
        private string nomePaciente;

        public int Id { get => id; set => id = value; }
        public DateTime DataReceita { get => dataReceita; set => dataReceita = value; }
        public DateTime DataValidade { get => dataValidade; set => dataValidade = value; }
        public string IdFuncionario { get => idFuncionario; set => idFuncionario = value; }
        public string NomeFuncionario { get => nomeFuncionario; set => nomeFuncionario = value; }
        public string IdPaciente { get => idPaciente; set => idPaciente = value; }
        public string Medicamento { get => medicamento; set => medicamento = value; }
        public string Detalhes { get => detalhes; set => detalhes = value; }
        public int LimitesBaixas { get => limitesBaixas; set => limitesBaixas = value; }
        public bool Valido { get => valido; private set => valido = value; }
        public int Baixas { get => baixas; set => baixas = value; }

        public Receita(DataTable dtReceita, int idReceita)
        {
            Id = int.Parse(dtReceita.Rows[idReceita]["ID_Receita"].ToString());
            dataReceita = DateTime.Parse(dtReceita.Rows[idReceita]["Data_Receita"].ToString());
            dataValidade = DateTime.Parse(dtReceita.Rows[idReceita]["Data_Validade"].ToString());
            idFuncionario = dtReceita.Rows[idReceita]["Funcionar_Rec"].ToString();
            nomeFuncionario = dtReceita.Rows[idReceita]["Funcionar_Nome"].ToString();
            idPaciente = dtReceita.Rows[idReceita]["Paciente_F"].ToString();
            medicamento = dtReceita.Rows[idReceita]["Medicamento"].ToString();
            detalhes = dtReceita.Rows[idReceita]["Detalhes"].ToString();
            limitesBaixas = int.Parse(dtReceita.Rows[idReceita]["Limite_Baixas"].ToString());
            valido = bool.Parse(dtReceita.Rows[idReceita]["Valido"].ToString());
            baixas = int.Parse(dtReceita.Rows[idReceita]["Baixas"].ToString());
        }
    }
}
