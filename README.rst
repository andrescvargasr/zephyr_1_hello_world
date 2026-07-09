.. zephyr:code-sample:: hello_world
   :name: Hello World

   Print "Hello World" to the console.

Overview
********

A simple sample that can be used with any :ref:`supported board <boards>` and
prints "Hello World" to the console.

Building and Running
********************

This application can be built and executed on QEMU as follows:

.. zephyr-app-commands::
   :zephyr-app: samples/hello_world
   :host-os: unix
   :board: qemu_x86
   :goals: run
   :compact:

To build for another board, change "qemu_x86" above to that board's name.

Multi-board build script
***********************

You can also use the provided script to build multiple boards in parallel directories:

.. code-block:: console

    ./build_all_boards.sh qemu_x86 qemu_x86_64
    ./build_all_boards.sh -b qemu_x86,native_posix
    ./build_all_boards.sh -c qemu_x86

The script creates separate build directories under ``build/<board>`` and runs ``west build`` for each board.

Use ``--list`` to show the configured boards in ``boards.env`` without building:

.. code-block:: console

    ./build_all_boards.sh --list

Sample Output
=============

.. code-block:: console

    Hello World! x86

Exit QEMU by pressing :kbd:`CTRL+A` :kbd:`x`.
