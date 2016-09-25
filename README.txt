Entre os comandos, sempre execute:
$ git status

Ele diz o estado do seu repositório local (o que está no computador).


Siga estes passos sempre que alterar algo no projeto:

TIPO DE ALTERAÇÃO:
	- Criou um novo arquivo:
	$ git status
	//Irá aparecer o nome do arquivo em vermelho, indicando que ele não está sendo monitorando ainda pelo seu repositorio local.

	$ git add "NomeDoProjeto.extensão"

	$ git status
	//Irá aparecer o nome deste arquivo em verde, indicando que ele está sendo monitorado mas que ainda precisa ser commitado.

	$ git commit -m "Mensagem descrevendo suas alterações"
	
	$ git status
	//Irá aparecer que vc precisa atualizar o repositório na nuvem (git push).

	$ git push origin master

	$ git status
	//Dirá que não há mais modificações e que tudo está OK.


	- Modificou um arquivo que já está sendo monitorado pelo git (já passou pelo git add):
	$ git status
	//Irá mostrar o nome do arquivo em verde, indicando que algo foi alterado e precisa ser commitado.

	$ git commit -m "Mensagem descrevendo suas alterações"

	$ git status
	//Irá aparecer que vc precisa atualizar o repositório na nuvem (git push).

	$ git push origin master

	$ git status
	//Dirá que não há mais modificações e que tudo está OK.


	- Caso tente o comando <git push origin master> e dê erro:
	$ git pull

	//Irá baixar o que há no repositório na nuvem e fazer um merge com o seu commit atual.

	Logo após isto, tente compilar o programa e verificar se tudo está OK antes de mandar para o repositório da nuvem.

	$ git push origin master


SEMPRE antes de iniciar o seu trabalho, abra o git, digite o comando <git pull>, abra o projeto e verifique se tudo está funcionando, e então comece a trabalhar.

Lembre-se de só fazer <git commit> quando você testar o projeto e verificar que tudo está funcionando.
