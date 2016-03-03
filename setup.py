from setuptools import setup, find_packages

setup(name='virtualfish',
    version='1.0.1', # Don't forget to change this in docs/conf.py and virtual.fish too!
    description='A virtualenv wrapper for the Fish shell',
    author='Adam Brenecki',
    author_email='adam@brenecki.id.au',
    url='https://github.com/adambrenecki/virtualfish',
    packages=find_packages(),
    package_data={'': ['*.fish']},
    include_package_data=True,
    setup_requires=[
        'setuptools_git>=0.3',
    ],
    install_requires=[
        'virtualenv',
    ],
    classifiers = [
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Topic :: System :: Shells',
    ]
)
