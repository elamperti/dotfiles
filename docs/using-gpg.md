# Using GPG

:package: You may need to add the `gnupg` package.

## Generating a key

Start the key generation wizard:
```
gpg --full-generate-key
```

  * Please select what kind of key you want: **(1) RSA and RSA (default)**
  * What keysize do you want? **4096**
  * Key is valid for? **1y**
  * Is this correct? **y**
  * Real name: **Your name**
  * Email address: **your_email@example.com**
  * Comment: **Leave empty** (unless you have a good reason to add one)
  * Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? **O**
  * Enter passphrase: **Use a secure password here**, keep it strong and remember you will have to type it frequently

## Making it publicly available

Before publishing your key you must find out its ID.

```
gpg --list-keys --keyid-format SHORT  your_email@example.com
```

The output of that command will be similar to this:
```
pub   rsa4096/1234B1F3 2020-05-10
              ‾‾‾‾‾‾‾‾
uid                    Your name <your_email@example.com>
sub   rsa4096/5678ADE5 2020-05-10
```

Our key ID in this example is `1234B1F3`, and with that we can publish it:

```
gpg --send-keys --keyserver pgp.mit.edu 1234B1F3
```
