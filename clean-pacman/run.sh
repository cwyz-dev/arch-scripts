if [ $# -eq 0 ] ; then echo "Usage: $0 [-k packages]" exit 1
fi

while [ $# -gt 0 ] ; do
	case "$1" in
		-k)
			shift
			sudo pacman -D --asdeps $(pacman -Qqe)
			sudo pacman -D --asexplicit "$@"
			break
			;;
		*)
			echo "ERROR | Usage: $0 [-k package]"
			exit 1
			;;
	esac
done

sudo pacman -Qdtq | sudo pacman -Rns -
sudo pacman -Syu
