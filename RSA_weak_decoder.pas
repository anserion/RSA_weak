//Copyright 2017 Andrey S. Ionisyan (anserion@gmail.com)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

//учебный шаблон быстрого возведения в степень и нахождения остатка
//от деления (используется в RSA-технологии для декодирования)
//
//в данной программе производится нарезка входного бинарного кода
//на блоки размером, совпадающим с размером модуля деления (в битах),
//так как после этапа RSA-кодирования каждый из таких блоков
//гарантированно будет иметь числовое значение, меньшее числового
//значения модуля деления.
//Выходной бинарный код компонуется из блоков, размером на 1 бит меньше
//размера модуля деления, так как при правильном декодировании будут
//получаться блоки с нулем в старшем разряде блока
program RSA_weak_decoder;
var
   n,e:integer; //входные модуль и степень декодирования
   s,ss:string; //входной битовый вектор и его блок
   c,cc:string; //выходной битовый вектор и его блок
   s_dec:integer; //входное число (блок) для возведения в степень
   c_dec:integer; //результат (для отдельного блока) в числовой форме
   i,j,n_size,blocks_num,align_s,pow_tmp,tmp:integer; //вспомогательные переменные
begin
   //ввод исходных данных
   writeln('RSA power and modulo operation (decode stage)');
   writeln('n - number, power - number, s - text (binary code)');
   //ввод модуля для вычисления остатка
   write('n='); readln(n);
   //вычисление размера блока
   n_size:=0; tmp:=1; while tmp<n do begin tmp:=tmp*2; n_size:=n_size+1; end;
   writeln('input block size=',n_size);
   writeln('output block size=',n_size-1);
   //ввод показателя степени
   write('power='); readln(e);
   //ввод бинарного кода для разбиения на блоки и RSA-обработки
   write('s=');readln(s);
   //выравнивание входного бинарного кода путем добавления нулей слева
   align_s:=n_size-(length(s) mod n_size);
   if align_s=n_size then align_s:=0;
   for i:=1 to align_s do s:='0'+s;
   //печать выровненного входного бинарного кода
   writeln('===========================');
   writeln('add ',align_s,' zero bits to S');
   for i:=1 to length(s) do
   begin
      write(s[i]);
      if (i mod n_size)=0 then write(' ');
   end;
   writeln;
   writeln('===========================');

   //расчет числа блоков
   blocks_num:=length(s) div n_size;
   c:='';
   for i:=1 to blocks_num do
   begin
      //вырезаем блок из выровненного входного бинарного кода
      //и добавляем нуль слева, чтобы избежать превышения n
      ss:='';
      for j:=1 to n_size do ss:=ss+s[(i-1)*n_size+j];
      //переводим блок из текстового (бинарного) в числовой формат
      s_dec:=0;
      for j:=1 to n_size do
      begin
         s_dec:=s_dec*2;
         if ss[j]='1' then s_dec:=s_dec+1;
      end;
      
      //быстрое возведение в степень с нахождением остатка на каждом шаге 
      c_dec:=1; pow_tmp:=e; tmp:=s_dec;
      while pow_tmp>0 do
         if (pow_tmp mod 2)=0 then
         begin
            tmp:=(tmp*tmp) mod n;
            pow_tmp:=pow_tmp div 2;
         end else
         begin
            c_dec:=(c_dec*tmp) mod n;
            pow_tmp:=pow_tmp-1;
         end;

      //перевод выходного блока из числового в текстовый (бинарный) формат
      //(на 1 бит меньше размера входного блока)
      cc:=''; tmp:=c_dec;
      for j:=1 to n_size-1 do
      begin
         if (tmp mod 2)=1 then cc:='1'+cc else cc:='0'+cc;
         tmp:=tmp div 2;
      end;
      //наращивание окончательного ответа
      c:=c+cc;
      //печать промежуточного результата
      writeln('block',i:3,': s=',ss,'=',s_dec:4,'    c=',cc,'=',c_dec:4);
   end;
   writeln('===========================');
   writeln('decode result');
   for i:=1 to length(c) do
   begin
      write(c[i]);
      if (i mod (n_size-1))=0 then write(' ');
   end;
   writeln;

   //"отрезаем" нули и одну единицу слева от декдированного ответа
   //для извлечения исходного сообщения
   j:=1; while c[j]='0' do j:=j+1;
   j:=j+1; cc:=c; c:='';
   for i:=j to length(cc) do c:=c+cc[i];
   
   //печать окончательного результата
   writeln('===========================');
   writeln('binary result');
   writeln(c);
end.
