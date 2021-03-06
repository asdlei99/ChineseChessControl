#include "MainWindow.h"
#include "FrmChineseChess.h"
#include "RabbitCommonDir.h"
#include "RabbitCommonTools.h"
#include "FrmUpdater/FrmUpdater.h"

#include <QApplication>
#include <QDebug>
#include <QTranslator>

int main(int argc, char *argv[])
{
    int nRet = 0;
    QApplication a(argc, argv);
    
    QString szLoacleName = QLocale::system().name();
    RabbitCommon::CTools::Instance()->Init(szLoacleName);
    CFrmChineseChess::InitResource(szLoacleName);

    QString qmFile = RabbitCommon::CDir::Instance()->GetDirTranslations()
            + QDir::separator() + "ChineseChessApp_" + szLoacleName + ".qm";

    QTranslator translator;
    translator.load(qmFile);
    qApp->installTranslator(&translator);

#ifdef RABBITCOMMON 
    CFrmUpdater *pUpdate = new CFrmUpdater();
    pUpdate->SetTitle(QImage(":/image/Chess"));
    pUpdate->SetInstallAutoStartup();
    if(!pUpdate->GenerateUpdateXml())
        return 0;
#endif
    
    MainWindow w;
    w.show();
    
    nRet = a.exec();
    
    qApp->removeTranslator(&translator);
    CFrmChineseChess::CleanResource();
    RabbitCommon::CTools::Instance()->Clean();
    
    return nRet;
}
