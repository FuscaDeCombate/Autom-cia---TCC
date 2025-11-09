using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;

namespace Automácia
{
    public class Valores
    {
        private static Point coordenadaChat;

        public Point CoordenadaChat { get => coordenadaChat; set => coordenadaChat = value; }


        private static Point coordenadaReceita;

        public Point CoordenadaReceita { get => coordenadaReceita; set => coordenadaReceita = value; }

    }
}
