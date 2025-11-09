using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Media;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Automácia
{
    public partial class TelaLogin : Form
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Declaração das Telas de cada tipo de Funcionário----------
        private TelaFuncoesAdminHospital objTelaFuncoesAdminHospital;
        private TelaFuncoesFuncHospital objTelaFuncoesFuncHospital;
        private TelaFuncoesAdminFarmacia objTelaFuncoesAdminFarmacia;
        private TelaVerificarReceitaFuncFarmacia objTelaVerificarReceitaFuncFarmacia;



        public TelaLogin()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }



        private void TelaLoginFuncHospital_Load(object sender, EventArgs e)
        {
            //---------------------------------------------Parte do Login--------------------------------------------
            //----------Arredondar Painel Principal----------
            EstiloUtils.ArredondarTudo(PnlLogin, 15);


            //----------Arredondar controles----------
            // Buttons
            EstiloUtils.ArredondarTudo(BtnEntrar, 30);


            //----------Aplicar a fonte personalizada nos controles----------
            // Textboxs
            FonteUtils.AplicarFonte(TxtID, "Inter-Regular", 20f, FontStyle.Regular);
            FonteUtils.AplicarFonte(TxtSenha, "Inter-Regular", 20f, FontStyle.Regular);

            // Labels
            FonteUtils.AplicarFonte(LblInforme, "Inter-Bold", 36f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblID, "Inter-Bold", 16.5f, FontStyle.Bold);
            FonteUtils.AplicarFonte(LblSenha, "Inter-Bold", 16.5f, FontStyle.Bold);

            // Buttons
            FonteUtils.AplicarFonte(BtnEntrar, "Inter-Medium", 22f, FontStyle.Regular);
        }



        //---------------------------------------------Parte do Login--------------------------------------------
        //----------Paint dos Elementos----------
        // Fundo do Textbox do CPF
        private void PnlTxtBoxCPF_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do Textbox da Senha
        private void PnlTxtBoxSenha_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBorda(e, sender, 2, false, true, false, false, Color.Black);
        }

        // Fundo do Button de Entrar
        private void BtnEntrar_Paint(object sender, PaintEventArgs e)
        {
            EstiloUtils.DesenharBordaTodaArredondada(e, sender, 2, 30, Color.Black);
        }


        //----------Evento KeyDown dos Elementos----------
        // Para redirecionar para o próximo elemento depois de já preenchido esse espaço
        private void RedirecionarProximo_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                // Verificar se a tecla apertada foi Enter
                if (e.KeyCode == Keys.Enter)
                {
                    Control controle = sender as Control;

                    switch (controle.Name)
                    {
                        case "TxtID":
                            TxtSenha.Focus();
                            break;
                        case "TxtSenha":
                            Login();
                            break;
                        case "BtnEntrar":
                            Login();
                            break;
                        default:
                            TxtID.Focus();
                            break;
                    }

                    e.Handled = true;
                    e.SuppressKeyPress = true; // impede o "beep" padrão
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
        }


        //----------Evento KeyPress dos Elementos----------
        // Para permitir apenas números e teclas de controle (como Backspace)
        private void TxtCPF_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }


        //----------Evento Click dos Elementos----------
        // Button de Entrar
        private void BtnEntrar_Click(object sender, EventArgs e)
        {
            try
            {
                Login();
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
            }
        }



        //---------------------------------------------Parte de fechar o programa---------------------------------------------
        //----------Evento ativado quando o formulário estiver sendo fechado----------
        private void TelaLoginFuncHospital_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!Sessao.saindo)
            {
                // Confirmação para ver se o programa realmente vai ser fechado
                var confirmar = MessageBox.Show("Deseja realmente sair?", "Sair", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                // Verificar se o usuário confirmou o fechamento
                if (confirmar == DialogResult.Yes)
                {
                    // Para fechar a Aplicação
                    Sessao.saindo = true;
                    Application.Exit();
                }
                else
                {
                    // Para cancelar o fechamento
                    e.Cancel = true;
                }
            }
        }


        //----------Evento ativado quando o formulário for fechado----------
        private void TelaLoginFuncHospital_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }



        //---------------------------------------------Parte de outras funções---------------------------------------------
        //----------Função de Login----------
        private void Login()
        {
            try
            {
                // Para verificar se o controle está vazio, e então deixar esse controle em Focus()
                foreach (var controle in new[] { TxtID, TxtSenha })
                {
                    if (string.IsNullOrWhiteSpace(controle.Text))
                    {
                        controle.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Preencha todos os campos!", "ATENÇÃO!!!");
                        return;
                    }
                }

                // Declaração das variáveis mais comuns
                int id = int.Parse(TxtID.Text);
                string senha = TxtSenha.Text;

                // Declaração da Classe que pega do Banco e do DataTable necessário
                ClsBanco objBanco = new ClsBanco();
                DataTable retornoLogin = objBanco.LoginFuncionario(id, senha);

                // Verificar se o login é Válido
                if (retornoLogin.Columns.Count > 1)
                {
                    // Declarar o forms que vai ser criado após o login
                    Form objForm = null;

                    // Switch para redirecionar cada funcionário para o seu formulário adequado
                    switch (Convert.ToInt32(retornoLogin.Rows[0]["ID_Tipo_Funcionario"]))
                    {
                        // Para o Funcionário comum da Farmácia
                        case 1:
                            if (objTelaVerificarReceitaFuncFarmacia == null || objTelaVerificarReceitaFuncFarmacia.IsDisposed)
                                objTelaVerificarReceitaFuncFarmacia = new TelaVerificarReceitaFuncFarmacia();

                            objForm = objTelaVerificarReceitaFuncFarmacia;
                            break;

                        // Para o Funcionário comum do Hospital
                        case 2:
                            if (objTelaFuncoesFuncHospital == null || objTelaFuncoesFuncHospital.IsDisposed)
                                objTelaFuncoesFuncHospital = new TelaFuncoesFuncHospital();

                            objForm = objTelaFuncoesFuncHospital;
                            break;

                        // Para o Funcionário Administrador da farmácia
                        case 3:
                            if (objTelaFuncoesAdminFarmacia == null || objTelaFuncoesAdminFarmacia.IsDisposed)
                                objTelaFuncoesAdminFarmacia = new TelaFuncoesAdminFarmacia();

                            objForm = objTelaFuncoesAdminFarmacia;
                            break;

                        // Para o Funcionário Administrador do Hospital
                        case 4:
                            if (objTelaFuncoesAdminHospital == null || objTelaFuncoesAdminHospital.IsDisposed)
                                objTelaFuncoesAdminHospital = new TelaFuncoesAdminHospital();

                            objForm = objTelaFuncoesAdminHospital;
                            break;

                        // Para o Nenhum Funcionário Válido
                        default:
                            TxtID.Focus();
                            SystemSounds.Beep.Play(); // cria o "beep" padrão
                            MessageBox.Show("Verifique as credenciais inseridas!", "Funcionário não identificado!!!");
                            break;
                    }

                    // Caso o Funcionário seja Válido
                    if (objForm != null)
                    {
                        // Para resetar as informações inseridas
                        TxtID.Text = "";
                        TxtSenha.Text = "";

                        // Para manter as informações do Funcionário logado
                        Funcionario.Id = Convert.ToInt32(retornoLogin.Rows[0]["Funcionar_Rec"]);
                        Funcionario.IdTipo = Convert.ToInt32(retornoLogin.Rows[0]["ID_Tipo_Funcionario"]);
                        Funcionario.Cnpj = Convert.ToInt32(retornoLogin.Rows[0]["CNPJ"]);
                        Funcionario.Nome = retornoLogin.Rows[0]["Nome_Funcionario"].ToString();

                        // Para exibir novo forms e esconder esse
                        objForm.Show();
                        this.Hide();
                    }
                    else
                    {
                        // Caso o Funcionário seja Inválido
                        TxtID.Focus();
                        SystemSounds.Beep.Play(); // cria o "beep" padrão
                        MessageBox.Show("Verifique as credenciais inseridas!", "Funcionário não identificado!!!");
                    }
                }
                else
                {
                    // Caso o Login seja Inválido
                    TxtID.Focus();
                    SystemSounds.Beep.Play(); // cria o "beep" padrão
                    MessageBox.Show("Verifique as credenciais inseridas!", "Funcionário não identificado!!!");
                }
            }
            catch (Exception ex)
            {
                // Caso algo dê errado, geralmente quando a conexão com o Banco deu errado
                Console.WriteLine(ex.ToString());
                MessageBox.Show("Verifique a sua conexão com o Banco!", "ATENÇÃO!!!");
            }
        }
    }
}
