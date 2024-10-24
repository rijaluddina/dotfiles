#!/bin/sh

if dpkg -s git >/dev/null 2>&1; then
  EXISTS_GIT="y"
else
  EXISTS_GIT="n"
  echo "Git tidak ditemukan. Silakan instal git terlebih dahulu."
  exit 1
fi

# Jika git sudah terinstal, lanjutkan dengan pengaturan
if [ $EXISTS_GIT = "y" ]; then
  echo ""
  read -p "Do first time setup for git? ([y]/n) " DO_GIT
  DO_GIT=${DO_GIT:-y}

  if [ $DO_GIT = "y" ]; then
    # Konfigurasi pengguna git
    read -p "For which user shall git be set up? [root] " USER_NAME
    USER_NAME=${USER_NAME:-root}
    read -p "Please enter your name for git: " NAME
    su -c "git config --global user.name \"${NAME}\"" "$USER_NAME"
    read -p "Please enter your E-Mail for git: " EMAIL
    su -c "git config --global user.email \"${EMAIL}\"" "$USER_NAME"
    echo "Git has been configured for user: $USER_NAME with name: $NAME and email: $EMAIL"

    # Opsional: Generate SSH key
    read -p "Generate SSH key? ([y]/n) " DO_GENERATE_KEY
    DO_GENERATE_KEY=${DO_GENERATE_KEY:-y}
    if [ $DO_GENERATE_KEY = "y" ]; then
      echo "Generating SSH key..."
      su -c "ssh-keygen -t ed25519 -C \"$EMAIL\"" "$USER_NAME"

      # Menampilkan instruksi untuk menambahkan kunci SSH ke GitHub
      echo "SSH key has been generated. Follow the instructions to add the SSH key to your GitHub account: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
    fi

    # Opsional: Generate GPG key
    read -p "Generate GPG key for signing commits? ([y]/n) " DO_GENERATE_GPG
    DO_GENERATE_GPG=${DO_GENERATE_GPG:-y}
    if [ $DO_GENERATE_GPG = "y" ]; then
      echo "Generating GPG key..."
      su -c "gpg --full-generate-key" "$USER_NAME"

      # Menampilkan daftar kunci GPG dan memerintahkan pengguna memilih kunci untuk konfigurasi Git
      GPG_KEY_ID=$(su -c "gpg --list-secret-keys --keyid-format LONG | grep 'sec' | awk '{print \$2}' | cut -d'/' -f2" "$USER_NAME")

      if [ -z "$GPG_KEY_ID" ]; then
        echo "No GPG key found, key generation might have failed."
      else
        su -c "git config --global user.signingkey $GPG_KEY_ID" "$USER_NAME"
        su -c "git config --global commit.gpgSign true" "$USER_NAME"

        # Menampilkan instruksi untuk menambahkan GPG key ke GitHub
        echo "GPG key has been generated and configured for Git. Follow the instructions to add the GPG key to your GitHub account: https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account"
        echo "To export your public GPG key, use: gpg --armor --export $GPG_KEY_ID"
      fi
    fi
  else
    echo "Git setup skipped."
  fi
fi
